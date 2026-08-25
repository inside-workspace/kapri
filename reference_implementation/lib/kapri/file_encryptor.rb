require "openssl"

module Kapri
  # AES-256-GCM file encryption per T1 SS2.4.1. Every encrypted Package File
  # gets its own random File Key - there is no shared package-wide key. The
  # File Key is only returned, never persisted by this module; safekeeping
  # is the caller's responsibility (see PackageGeneration.generate_package_files).
  #
  # Nonce, ciphertext and authentication tag are not tracked separately but
  # embedded directly in the stored bytes, prefixed with the fixed 8-octet
  # magic value KAPENC01 (T1 SS2.4.1): magic || nonce || ciphertext ||
  # authentication_tag. The Packing List records the hash and size of this
  # complete encrypted representation and uses key_id to reference its key.
  module FileEncryptor
    ALGORITHM    = "AES-256-GCM".freeze
    MAGIC        = "KAPENC01".b.freeze
    NONCE_LENGTH = 12 # bytes, standard for GCM
    TAG_LENGTH   = 16 # bytes, standard for GCM
    MIN_STORED_LENGTH = MAGIC.bytesize + NONCE_LENGTH + TAG_LENGTH

    Encrypted = Struct.new(:stored_bytes, :file_key, keyword_init: true)

    def self.encrypt(plaintext)
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.encrypt
      file_key = cipher.random_key
      nonce    = cipher.random_iv
      ciphertext = cipher.update(plaintext) + cipher.final
      tag = cipher.auth_tag(TAG_LENGTH)

      Encrypted.new(stored_bytes: MAGIC + nonce + ciphertext + tag, file_key: file_key)
    end

    # T1 SS2.4.1: decryption SHALL fail if the magic value is not KAPENC01,
    # if the encrypted representation is malformed, or if authentication-tag
    # validation fails (the last case is OpenSSL::Cipher::CipherError,
    # raised by cipher.final below).
    def self.decrypt(stored_bytes:, file_key:)
      raise "Verschlüsselte Repräsentation ist fehlerhaft (zu kurz)" if stored_bytes.bytesize < MIN_STORED_LENGTH

      magic = stored_bytes.byteslice(0, MAGIC.bytesize)
      raise "Ungültiger magic-Wert (erwartet #{MAGIC.inspect}, erhalten #{magic.inspect})" unless magic == MAGIC

      nonce      = stored_bytes.byteslice(MAGIC.bytesize, NONCE_LENGTH)
      tag        = stored_bytes.byteslice(-TAG_LENGTH, TAG_LENGTH)
      ciphertext = stored_bytes.byteslice((MAGIC.bytesize + NONCE_LENGTH)...-TAG_LENGTH)

      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.decrypt
      cipher.key      = file_key
      cipher.iv       = nonce
      cipher.auth_tag = tag
      cipher.update(ciphertext) + cipher.final
    end
  end
end
