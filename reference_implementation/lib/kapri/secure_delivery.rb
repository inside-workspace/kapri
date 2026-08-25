require "json"
require "fileutils"
require "openssl"
require "securerandom"
require_relative "hasher"
require_relative "signer"
require_relative "file_encryptor"
require_relative "document_validation"
require_relative "schema_validation"
require_relative "workspace"

module Kapri
  # T4 - Secure Delivery reference implementation.
  #
  # Implements the six-step delivery workflow defined by specification/16:
  # T4.md SS3: Encrypt File Keys for Recipient -> Generate KAP-KDM -> Sign
  # KAP-KDM -> Validate KAP-KDM -> Recover File Keys -> Decrypt Package
  # Files.
  #
  # T4 SS1.3 requires T3 (Package Validation) to have completed
  # successfully first, and operates on a Package whose Files were already
  # encrypted during T2.2 (Encrypt Package Files) - encrypting Package
  # Files is T2's concern (Package Generation), not T4's; T4 owns only the
  # producer-to-recipient key-delivery lifecycle around File Keys that
  # already exist. T4.1 therefore reads the File Keys T2.2 produced (via
  # generate_file_keys, a private helper - "Generate File Keys" is not
  # itself a T4 conformance test) rather than generating new ones.
  #
  # T4.1-T4.3 and T4.5-T4.6 are producer-/consumer-side generation and
  # recovery steps - like T1/T2 they raise on a missing prerequisite
  # (script not yet run in order) rather than degrading gracefully. T4.4
  # (Validate KAP-KDM) is a validator like T3 and never raises on a
  # malformed or malicious KDM; producing "INVALID, with reasons" is the
  # point.
  module SecureDelivery
    CategoryResult = Struct.new(:name, :valid, :errors, keyword_init: true)

    # Not a T4 conformance test itself (File Key generation is T2.2's
    # concern) - a private-in-spirit helper used by T4.1 (encrypt_file_keys)
    # to read the File Keys T2.2 already produced.
    #
    # Returns the File Keys produced when T2.2 encrypted the Package
    # Files (Base64url-encoded, keyed by key_id).
    def self.generate_file_keys(output_dir:)
      state = read_internal_json(output_dir, "_package_files.json")
      file_keys = state.fetch("file_keys", {})
      raise "Keine File Keys vorhanden - T2.2 (Encrypt Package Files) ausführen" if file_keys.empty?

      file_keys
    end

    # RSA-OAEP-256 per T1 SS2.4.3: SHA-256 for both the OAEP hash and MGF1,
    # empty label. OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING (the legacy
    # public_encrypt/private_decrypt API) hardcodes SHA-1 for both and
    # cannot be parameterized, so this uses the newer encrypt/decrypt API
    # (openssl gem >= 3.0) instead.
    OAEP_OPTIONS = { rsa_padding_mode: "oaep", rsa_oaep_md: "SHA256", rsa_mgf1_md: "SHA256" }.freeze

    # T4.1 - Encrypt File Keys for Recipient
    #
    # Wraps every File Key with the Recipient's public key (RSA-OAEP-256,
    # matching the "keyEncipherment" usage T1 assigns to the Recipient
    # Certificate).
    def self.encrypt_file_keys(output_dir:, pki_dir:)
      file_keys = generate_file_keys(output_dir: output_dir)

      recipient_cert = read_certificate(pki_dir, "recipient", "recipient")
      recipient_public_key = recipient_cert.public_key

      key_entries = file_keys.map do |key_id, encoded_key|
        raw_key = Hasher.decode_base64url(encoded_key)
        wrapped = recipient_public_key.encrypt(raw_key, **OAEP_OPTIONS)
        { "key_id" => key_id, "encrypted_file_key" => Hasher.base64url(wrapped) }
      end

      write_internal_json(output_dir, "_key_entries.json", { "key_entries" => key_entries })
      key_entries
    end

    # T4.2 - Generate KAP-KDM (without signature - see T4.3)
    #
    # S4 SS3.2.6 requires the KAP-KDM to identify the Recipient Certificate
    # whose public key encrypted the File Keys (T4.1) - the same
    # certificate read_certificate(pki_dir, "recipient", "recipient")
    # returns, embedded as an SC1 SS4.13 Certificate Reference.
    def self.generate_kdm(output_dir:, pki_dir:,
                           recipient_organization_id:,
                           recipient_organization_name:,
                           schema_version: "0.9.0")
      state = read_internal_json(output_dir, "_key_entries.json")
      key_entries = state.fetch("key_entries")
      raise "Keine verpackten File Keys vorhanden - T4.1 zuerst ausführen" if key_entries.empty?

      _bytes, manifest = read_json_bytes(File.join(Workspace.package_dir(output_dir), "manifest.json"))
      raise "manifest.json fehlt oder ist ungültig - T2.7 zuerst ausführen" unless manifest

      recipient_cert = read_certificate(pki_dir, "recipient", "recipient")

      kdm = {
        "document_type"  => "kap_kdm",
        "schema_version" => schema_version,
        "kdm_id"         => uuid_urn,
        "package_id"     => manifest.fetch("package_id"),
        "recipient"      => { "organization_id" => recipient_organization_id, "name" => recipient_organization_name },
        "recipient_certificate" => Signer.certificate_chain_entry(recipient_cert),
        "key_entries"    => key_entries
      }

      write_internal_json(output_dir, "_kdm_unsigned.json", kdm)
      kdm
    end

    # T4.3 - Sign KAP-KDM
    def self.sign_kdm(output_dir:, pki_dir:)
      kdm = read_internal_json(output_dir, "_kdm_unsigned.json")

      producer_cert, producer_key = read_certificate_and_key(pki_dir, "producer", "producer")
      intermediate_cert = read_certificate(pki_dir, "intermediate", "intermediate-ca")
      root_cert = read_certificate(pki_dir, "root", "root-ca")
      signed_kdm = Signer.sign_document(
        kdm, private_key: producer_key,
        certificate_chain: [producer_cert, intermediate_cert, root_cert]
      )
      write_document(output_dir, "kdm.json", signed_kdm)
      signed_kdm
    end

    # T4.4 - Validate KAP-KDM
    #
    # Structural validation (SC1 SS4.1-4.12 shapes referenced by S4) plus
    # signature and certificate-chain validation, mirroring T3's
    # validate_manifest/validate_signature/validate_certificate_chain but
    # for kdm.json - which, per S0 SS4.7, is not part of the Package and so
    # is validated independently with its own embedded certificate_chain
    # (SC1 SS4.13), no external PKI lookup required. Also validates the
    # embedded recipient_certificate and its correspondence to
    # recipient.organization_id (S4 SS3.2.6). Never raises - an invalid KDM
    # is a legitimate, reportable outcome.
    def self.validate_kdm(output_dir:)
      name = "Key Delivery Message"
      kdm, errors = DocumentValidation.load_json(Workspace.kdm_path(output_dir))
      return CategoryResult.new(name: name, valid: false, errors: errors) if kdm.nil?

      errors = SchemaValidation.validate(kdm, :kdm)
      return CategoryResult.new(name: name, valid: false, errors: errors) unless kdm.is_a?(Hash)
      errors.concat(DocumentValidation.validate_certificate_reference(kdm["recipient_certificate"], "recipient_certificate"))

      package_dir = Workspace.package_dir(output_dir)
      manifest, manifest_errors = DocumentValidation.load_json(File.join(package_dir, "manifest.json"))
      if manifest.is_a?(Hash)
        errors << "package_id entspricht nicht manifest.package_id" unless kdm["package_id"] == manifest["package_id"]
      else
        errors.concat(manifest_errors.empty? ? ["manifest.json muss ein Objekt sein"] : manifest_errors)
      end

      # S4 SS3.2.6: the Recipient Certificate's SAN uniformResourceIdentifier
      # SHALL exactly match recipient.organization_id.
      recipient_cert = DocumentValidation.parse_certificate(DocumentValidation.value_at(kdm, "recipient_certificate", "certificate"))
      if recipient_cert
        errors.concat(DocumentValidation.validate_recipient_certificate_profile(recipient_cert))
        organization_id = DocumentValidation.value_at(kdm, "recipient", "organization_id")
        sans = DocumentValidation.subject_alternative_name_uris(recipient_cert)
        errors << "recipient_certificate entspricht nicht recipient.organization_id (SAN: #{sans.inspect})" unless sans.include?(organization_id)
      end

      key_entries = kdm["key_entries"]
      if key_entries.is_a?(Array) && !key_entries.empty?
        seen_key_ids = Hash.new(0)
        key_entries.each_with_index do |entry, i|
          unless entry.is_a?(Hash)
            errors << "key_entries[#{i}] ist kein Objekt"
            next
          end
          unless DocumentValidation.base64url?(entry["encrypted_file_key"], decoded_length: 384)
            errors << "key_entries[#{i}].encrypted_file_key muss ein 384-Oktett RSA-OAEP-256-Ciphertext in Base64url ohne Padding sein"
          end
          seen_key_ids[entry["key_id"]] += 1 if entry["key_id"]
        end
        seen_key_ids.each { |id, count| errors << "key_id #{id} ist nicht eindeutig (#{count}x)" if count > 1 }
      else
        errors << "key_entries fehlt oder ist leer"
      end

      # S4 SS6: every KDM key_id must exist in the referenced Package's
      # Packing List. A recipient-specific KDM may contain only a subset.
      packing_list, pl_errors = DocumentValidation.load_json(File.join(package_dir, "packing-list.json"))
      if packing_list.nil?
        errors.concat(pl_errors)
      else
        packing_files = packing_list.is_a?(Hash) && packing_list["files"].is_a?(Array) ? packing_list["files"] : []
        entries = kdm["key_entries"].is_a?(Array) ? kdm["key_entries"] : []
        packing_list_key_ids = packing_files.filter_map { |f| f["key_id"] if f.is_a?(Hash) }
        kdm_key_ids = entries.filter_map { |e| e["key_id"] if e.is_a?(Hash) }

        kdm_key_ids.each do |key_id|
          errors << "key_id #{key_id} referenziert keinen Key Identifier der Packing List" unless packing_list_key_ids.include?(key_id)
        end
      end

      errors.concat(DocumentValidation.validate_signature_structure(kdm["signature"]))

      if errors.empty?
        certs, chain_errors = DocumentValidation.parse_certificate_chain(DocumentValidation.value_at(kdm, "signature", "certificate_chain"))
        if certs
          valid = Signer.verify_document(kdm, certs.first.public_key)
          errors << "digitale Signatur ist ungültig" unless valid
          errors.concat(DocumentValidation.validate_chain_integrity(certs))
          errors.concat(DocumentValidation.validate_reference_chain_profile(certs, leaf_role: :producer))
        else
          errors.concat(chain_errors)
        end
      end

      CategoryResult.new(name: name, valid: errors.empty?, errors: errors)
    end

    # T4.5 - Recover File Keys
    #
    # Consumer-side: unwraps every Encrypted File Key in kdm.json using the
    # Recipient's private key. Raises on cryptographic failure (wrong
    # recipient, corrupted KDM) - unlike T4.4, recovery is meant to
    # unambiguously succeed or fail, not produce a partial report.
    def self.recover_file_keys(output_dir:, pki_dir:)
      _bytes, kdm = read_json_bytes(Workspace.kdm_path(output_dir))
      raise "kdm.json fehlt oder ist ungültig - T4.3 zuerst ausführen" unless kdm

      recipient_key = read_private_key(pki_dir, "recipient", "recipient")
      embedded_recipient_cert = DocumentValidation.parse_certificate(DocumentValidation.value_at(kdm, "recipient_certificate", "certificate"))
      unless embedded_recipient_cert && embedded_recipient_cert.public_key.to_der == recipient_key.public_key.to_der
        raise "Recipient Private Key entspricht nicht dem in der KDM eingebetteten Recipient Certificate"
      end

      recovered = kdm.fetch("key_entries").each_with_object({}) do |entry, memo|
        encrypted_file_key = Hasher.decode_base64url(entry.fetch("encrypted_file_key"))
        raw_key = recover_file_key(encrypted_file_key, private_key: recipient_key)
        memo[entry.fetch("key_id")] = Hasher.base64url(raw_key)
      end

      write_internal_json(output_dir, "_recovered_file_keys.json", { "file_keys" => recovered })
      recovered
    end

    def self.recover_file_key(ciphertext, private_key:)
      raw_key = private_key.decrypt(ciphertext, **OAEP_OPTIONS)
      raise "Wiederhergestellter File Key hat nicht genau 32 Oktette" unless raw_key.bytesize == 32

      raw_key
    end

    # T4.6 - Decrypt Package Files
    #
    # Consumer-side: decrypts every Package File referenced by a key_id in
    # the Packing List using the corresponding recovered File Key
    # (AES-256-GCM; a wrong/corrupted key or tampered ciphertext raises
    # OpenSSL::Cipher::CipherError via the GCM authentication tag).
    # Plaintext is written under output_dir/decrypted/<path>.
    def self.decrypt_package_files(output_dir:)
      state = read_internal_json(output_dir, "_recovered_file_keys.json")
      recovered = state.fetch("file_keys")

      package_dir = Workspace.package_dir(output_dir)
      _bytes, packing_list = read_json_bytes(File.join(package_dir, "packing-list.json"))
      raise "packing-list.json fehlt oder ist ungültig" unless packing_list

      decrypted = []
      packing_list.fetch("files").each do |entry|
        key_id = entry["key_id"]
        next unless key_id

        encoded_key = recovered.fetch(key_id) { raise "Kein wiederhergestellter File Key für key_id #{key_id}" }
        file_key = Hasher.decode_base64url(encoded_key)

        path = entry.fetch("path")
        source = DocumentValidation.resolve_within(package_dir, path)
        raise "files[].path '#{path}' ist kein sicherer relativer Pfad (absolut, enthält '..', oder verlässt das Package-Verzeichnis)" unless source

        stored_bytes = File.binread(source)
        plaintext = FileEncryptor.decrypt(stored_bytes: stored_bytes, file_key: file_key)

        destination = File.join(Workspace.decrypted_dir(output_dir), path)
        FileUtils.mkdir_p(File.dirname(destination))
        File.binwrite(destination, plaintext)

        decrypted << { "path" => path, "destination" => destination, "size" => plaintext.bytesize }
      end

      decrypted
    end

    def self.uuid_urn = "urn:uuid:#{SecureRandom.uuid}"
    private_class_method :uuid_urn

    def self.read_certificate(pki_dir, role_dir, basename)
      OpenSSL::X509::Certificate.new(File.read(File.join(pki_dir, role_dir, "#{basename}.crt")))
    end
    private_class_method :read_certificate

    def self.read_private_key(pki_dir, role_dir, basename)
      OpenSSL::PKey.read(File.read(File.join(pki_dir, role_dir, "#{basename}.key")))
    end
    private_class_method :read_private_key

    def self.read_certificate_and_key(pki_dir, role_dir, basename)
      [read_certificate(pki_dir, role_dir, basename), read_private_key(pki_dir, role_dir, basename)]
    end
    private_class_method :read_certificate_and_key

    def self.write_document(output_dir, relative_path, hash)
      full_path = File.join(output_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, JSON.pretty_generate(hash) + "\n")
    end
    private_class_method :write_document

    def self.read_json_bytes(path)
      return [nil, nil] unless File.exist?(path)
      bytes = File.binread(path)
      [bytes, JSON.parse(bytes)]
    end
    private_class_method :read_json_bytes

    def self.internal_path(output_dir, name) = Workspace.state_path(output_dir, name)
    private_class_method :internal_path

    def self.write_internal_json(output_dir, name, hash)
      FileUtils.mkdir_p(Workspace.state_dir(output_dir))
      File.write(internal_path(output_dir, name), JSON.pretty_generate(hash))
    end
    private_class_method :write_internal_json

    def self.read_internal_json(output_dir, name)
      path = internal_path(output_dir, name)
      raise "#{path} fehlt - vorausgehender T4-Schritt wurde nicht ausgeführt" unless File.exist?(path)

      JSON.parse(File.read(path))
    end
    private_class_method :read_internal_json
  end
end
