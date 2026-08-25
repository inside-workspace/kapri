require "json"
require "openssl"
require_relative "canonicalization"
require_relative "file_encryptor"
require_relative "hasher"
require_relative "signer"
require_relative "secure_delivery"

module Kapri
  # T1.6 - executable positive and negative vectors for the Reference
  # Cryptographic Profile.
  module CryptographicProfile
    OAEP_OPTIONS = { rsa_padding_mode: "oaep", rsa_oaep_md: "SHA256", rsa_mgf1_md: "SHA256" }.freeze
    Result = Struct.new(:valid, :checks, :errors, keyword_init: true)

    module_function

    def validate(pki_dir:)
      checks = {}
      errors = []

      run(checks, errors, "SHA-256") do
        Hasher.sha256("abc") == "ungWv48Bz-pBQUDeXa4iI7ADYaOWF3qctBD_YfIAFa0"
      end

      encrypted = FileEncryptor.encrypt("KAPRI test vector".b)
      run(checks, errors, "A256GCM round-trip") do
        encrypted.file_key.bytesize == 32 &&
          encrypted.stored_bytes.start_with?(FileEncryptor::MAGIC) &&
          FileEncryptor.decrypt(stored_bytes: encrypted.stored_bytes, file_key: encrypted.file_key) == "KAPRI test vector"
      end
      run(checks, errors, "A256GCM altered ciphertext rejected") do
        rejects? { FileEncryptor.decrypt(stored_bytes: alter(encrypted.stored_bytes, FileEncryptor::MAGIC.bytesize + FileEncryptor::NONCE_LENGTH), file_key: encrypted.file_key) }
      end
      run(checks, errors, "A256GCM altered authentication tag rejected") do
        rejects? { FileEncryptor.decrypt(stored_bytes: alter(encrypted.stored_bytes, -1), file_key: encrypted.file_key) }
      end
      run(checks, errors, "Malformed encrypted Package File rejected") do
        rejects? { FileEncryptor.decrypt(stored_bytes: "KAPENC01".b, file_key: encrypted.file_key) }
      end

      producer_key = read_key(pki_dir, "producer", "producer")
      canonical = Canonicalization.serialize("document_type" => "kap_test").b
      ps256 = producer_key.sign_pss(OpenSSL::Digest::SHA256.new, canonical, salt_length: 32, mgf1_hash: "SHA256")
      run(checks, errors, "PS256 signature generation and validation") do
        producer_key.public_key.verify_pss(OpenSSL::Digest::SHA256.new, ps256, canonical, salt_length: 32, mgf1_hash: "SHA256")
      end
      nonconforming_pss = producer_key.sign_pss(OpenSSL::Digest::SHA256.new, canonical, salt_length: 20, mgf1_hash: "SHA256")
      run(checks, errors, "PS256 non-conforming parameters rejected") do
        !producer_key.public_key.verify_pss(OpenSSL::Digest::SHA256.new, nonconforming_pss, canonical, salt_length: 32, mgf1_hash: "SHA256")
      end

      recipient_key = read_key(pki_dir, "recipient", "recipient")
      file_key = OpenSSL::Random.random_bytes(32)
      wrapped = recipient_key.public_key.encrypt(file_key, **OAEP_OPTIONS)
      recovered = recipient_key.decrypt(wrapped, **OAEP_OPTIONS)
      run(checks, errors, "RSA-OAEP-256 File Key recovery") do
        wrapped.bytesize == 384 && recovered == file_key && recovered.bytesize == 32
      end
      nonconforming_oaep = recipient_key.public_key.encrypt(
        file_key, rsa_padding_mode: "oaep", rsa_oaep_md: "SHA1", rsa_mgf1_md: "SHA1"
      )
      run(checks, errors, "RSA-OAEP non-conforming parameters rejected") do
        rejects? { SecureDelivery.recover_file_key(nonconforming_oaep, private_key: recipient_key) }
      end
      short_key_ciphertext = recipient_key.public_key.encrypt(OpenSSL::Random.random_bytes(31), **OAEP_OPTIONS)
      run(checks, errors, "RSA-OAEP result not exactly 32 octets rejected") do
        rejects? { SecureDelivery.recover_file_key(short_key_ciphertext, private_key: recipient_key) }
      end

      encoded_values = [Hasher.sha256("abc"), Hasher.base64url(ps256), Hasher.base64url(wrapped)]
      run(checks, errors, "Base64url without padding") do
        encoded_values.all? { |value| value.match?(/\A[A-Za-z0-9_-]+\z/) && !value.include?("=") }
      end

      Result.new(valid: errors.empty?, checks: checks, errors: errors)
    end

    def run(checks, errors, name)
      checks[name] = yield == true
      errors << "#{name}: fehlgeschlagen" unless checks[name]
    rescue StandardError => e
      checks[name] = false
      errors << "#{name}: #{e.class}: #{e.message}"
    end
    private_class_method :run

    def rejects?
      yield
      false
    rescue StandardError
      true
    end
    private_class_method :rejects?

    def alter(bytes, index)
      changed = bytes.dup
      index += changed.bytesize if index.negative?
      changed.setbyte(index, changed.getbyte(index) ^ 0x01)
      changed
    end
    private_class_method :alter

    def read_key(pki_dir, role, basename)
      OpenSSL::PKey.read(File.read(File.join(pki_dir, role, "#{basename}.key")))
    end
    private_class_method :read_key
  end
end
