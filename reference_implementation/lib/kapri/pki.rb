require "openssl"
require "fileutils"
require "digest"
require "base64"

module Kapri
  # Public Key Infrastructure implementation: reference certification hierarchy
  #
  #   Root Certification Authority
  #     -> Intermediate Certification Authority
  #        -> Producer Certificate
  #        -> Recipient Certificate
  #
  # T1 (reference_implementation/scripts/t1_public_key_infrastructure/t1_*.rb)
  # is the specification's PKI test
  # group and is currently the only consumer, but this module deliberately
  # lives outside the T1 namespace: it is the reusable implementation, T1 is
  # one specification that exercises it. Later test groups (e.g. T2 Package
  # Generation signing a Manifest) can call Kapri::PKI directly
  # without depending on T1.
  #
  # Pure Ruby stdlib (openssl, fileutils, digest) - no gem dependencies,
  # so these tests run identically inside or outside the app's bundle.
  #
  # Cryptographic Profile (T1 SS2.4/SS2.5): RSA-3072 for all four
  # certificate roles (Root CA, Intermediate CA, Producer, Recipient).
  module PKI
    KEY_BITS = 3072

    # Fixed reference date, not Time.now - every run produces byte-identical
    # certificate structure, which real random key material aside is the
    # point of a reference PKI fixture.
    VALID_FROM    = Time.utc(2026, 1, 1, 0, 0, 0)
    VALIDITY_DAYS = 365 * 5

    SERIALS = { root_ca: 1, intermediate_ca: 2, producer: 3, recipient: 4 }.freeze

    ROLE_DIRS = { root_ca: "root", intermediate_ca: "intermediate", producer: "producer", recipient: "recipient" }.freeze
    BASENAMES = { root_ca: "root-ca", intermediate_ca: "intermediate-ca", producer: "producer", recipient: "recipient" }.freeze

    # RSA wraps File Keys directly (RSA-OAEP) -> keyEncipherment.
    RECIPIENT_KEY_USAGE = "keyEncipherment"

    # T1 SS2.5.3: the Producer Certificate SHALL contain a Subject
    # Alternative Name with a uniformResourceIdentifier identifying the
    # organization it represents, identical to the
    # responsible_organization.organization_id used in Package Manifests
    # signed with this Producer Certificate (S1 SS3.2.9).
    DEFAULT_ORGANIZATION_ID = "urn:kap:organization:kapri-reference"

    # T1 SS2.5.4: the Recipient Certificate SHALL contain a Subject
    # Alternative Name with a uniformResourceIdentifier identifying the
    # Recipient organization, identical to the recipient.organization_id
    # used in a KAP Key Delivery Message for that Recipient (S4 SS3.2.5).
    DEFAULT_RECIPIENT_ORGANIZATION_ID = "urn:kap:organization:kapri-reference-recipient"

    Result = Struct.new(
      :certificate, :private_key, :crt_path, :key_path, :cer_path,
      :thumbprint_sha1, :thumbprint_sha256,
      keyword_init: true
    )
    ChainValidation = Struct.new(:valid, :errors, :producer_chain_path, :recipient_chain_path, keyword_init: true)

    def self.role_dir(output_dir, role) = File.join(output_dir, ROLE_DIRS.fetch(role))
    def self.crt_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}.crt")
    def self.key_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}.key")
    def self.cer_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}.cer")
    def self.sha1_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}.sha1")
    def self.sha256_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}.sha256")
    def self.text_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}.txt")
    def self.chain_path(output_dir, role) = File.join(role_dir(output_dir, role), "#{BASENAMES.fetch(role)}-chain.pem")

    def self.thumbprint_sha1(cert) = Digest::SHA1.hexdigest(cert.to_der)
    def self.thumbprint_sha256(cert) = Digest::SHA256.hexdigest(cert.to_der)

    # openssl x509 -fingerprint style: colon-separated uppercase hex.
    def self.fingerprint_line(label, hex) = "#{label} Fingerprint=#{hex.upcase.scan(/../).join(':')}"
    private_class_method :fingerprint_line

    def self.generate_key
      OpenSSL::PKey::RSA.generate(KEY_BITS)
    end
    private_class_method :generate_key

    # dnQualifier, modeled after the convention used by SMPTE 430-2 (DCI)
    # certificates: Base64-encoded SHA-1 hash of the subjectPublicKey BIT
    # STRING content (RFC 5280 Method 1) - the same input OpenSSL's own
    # `subjectKeyIdentifier "hash"` extension uses, confirmed empirically to
    # produce identical bytes to that extension. Disambiguates certificates
    # whose human-readable Subject (CN/O/C) collide, independent of
    # Hasher.certificate_id (which hashes the whole certificate, not just
    # the key).
    def self.dn_qualifier(key)
      pkcs1_der = OpenSSL::ASN1::Sequence.new([OpenSSL::ASN1::Integer.new(key.n), OpenSSL::ASN1::Integer.new(key.e)]).to_der
      Base64.strict_encode64(OpenSSL::Digest::SHA1.digest(pkcs1_der))
    end
    private_class_method :dn_qualifier

    # dnQualifier first (RFC 2253 renders array order in reverse), matching
    # the "dnQualifier=...,CN=...,O=...,OU=...,C=..." form.
    def self.subject_name(key, cn:)
      OpenSSL::X509::Name.new([
        ["C", "DE"], ["OU", "KAPRI Reference Implementation"], ["O", "inside workspace GmbH"],
        ["CN", cn], ["dnQualifier", dn_qualifier(key)]
      ])
    end
    private_class_method :subject_name

    # T1.1 - Generate Root Certification Authority
    def self.generate_root_ca(output_dir:)
      key  = generate_key
      name = subject_name(key, cn: "KAPRI Reference Root CA")

      cert = base_certificate(key, name, name, SERIALS.fetch(:root_ca))
      apply_ca_extensions(cert, cert, path_length: 1)
      cert.sign(key, OpenSSL::Digest::SHA256.new)

      write(output_dir, :root_ca, cert, key)
    end

    # T1.2 - Generate Intermediate Certification Authority
    def self.generate_intermediate_ca(output_dir:)
      root_cert, root_key = read(output_dir, :root_ca)

      key  = generate_key
      name = subject_name(key, cn: "KAPRI Reference Intermediate CA")

      cert = base_certificate(key, name, root_cert.subject, SERIALS.fetch(:intermediate_ca))
      apply_ca_extensions(cert, root_cert, path_length: 0)
      cert.sign(root_key, OpenSSL::Digest::SHA256.new)

      write(output_dir, :intermediate_ca, cert, key)
    end

    # T1.3 - Generate Producer Certificate
    # Used to sign Package Manifests and Key Delivery Messages.
    def self.generate_producer_certificate(output_dir:, organization_id: DEFAULT_ORGANIZATION_ID)
      issuer_cert, issuer_key = read(output_dir, :intermediate_ca)

      key  = generate_key
      name = subject_name(key, cn: "KAPRI Reference Producer")

      cert = base_certificate(key, name, issuer_cert.subject, SERIALS.fetch(:producer))
      apply_leaf_extensions(
        cert, issuer_cert, key_usage: "digitalSignature,contentCommitment", extended_key_usage: "codeSigning",
        subject_alternative_name: "URI:#{organization_id}"
      )
      cert.sign(issuer_key, OpenSSL::Digest::SHA256.new)

      write(output_dir, :producer, cert, key)
    end

    # T1.4 - Generate Recipient Certificate
    # Identifies the intended recipient of encrypted File Keys in a KDM.
    def self.generate_recipient_certificate(output_dir:, organization_id: DEFAULT_RECIPIENT_ORGANIZATION_ID)
      issuer_cert, issuer_key = read(output_dir, :intermediate_ca)

      key  = generate_key
      name = subject_name(key, cn: "KAPRI Reference Recipient")

      cert = base_certificate(key, name, issuer_cert.subject, SERIALS.fetch(:recipient))
      apply_leaf_extensions(
        cert, issuer_cert, key_usage: RECIPIENT_KEY_USAGE, extended_key_usage: nil,
        subject_alternative_name: "URI:#{organization_id}"
      )
      cert.sign(issuer_key, OpenSSL::Digest::SHA256.new)

      write(output_dir, :recipient, cert, key)
    end

    # T1.5 - Validate Certification Chain
    #
    # validation_time defaults to Time.now for everyday use, but accepts an
    # override (e.g. VALID_FROM + 365) so the validity-period check stays
    # reproducible - a reference PKI shouldn't start failing once its fixed
    # VALID_FROM window ages past VALIDITY_DAYS.
    def self.validate_certification_chain(output_dir:, validation_time: Time.now,
                                           organization_id: DEFAULT_ORGANIZATION_ID,
                                           recipient_organization_id: DEFAULT_RECIPIENT_ORGANIZATION_ID)
      errors = []

      root_cert, = read(output_dir, :root_ca)
      intermediate_cert, = read(output_dir, :intermediate_ca)
      producer_cert, = read(output_dir, :producer)
      recipient_cert, = read(output_dir, :recipient)

      store = OpenSSL::X509::Store.new
      store.add_cert(root_cert)

      intermediate_ctx = OpenSSL::X509::StoreContext.new(store, intermediate_cert, [])
      errors << "Intermediate CA verifiziert nicht gegen Root CA (Chain)" unless intermediate_ctx.verify

      [["Producer", producer_cert], ["Recipient", recipient_cert]].each do |label, cert|
        ctx = OpenSSL::X509::StoreContext.new(store, cert, [intermediate_cert])
        errors << "#{label}-Zertifikat verifiziert nicht gegen die Kette (Chain)" unless ctx.verify
      end

      # Direct signature verification per certificate, independent of the
      # X509::Store chain-of-trust check above.
      errors << "Root-CA-Signatur ungültig (self-signed)" unless root_cert.verify(root_cert.public_key)
      errors << "Intermediate-CA-Signatur ungültig" unless intermediate_cert.verify(root_cert.public_key)
      errors << "Producer-Zertifikat-Signatur ungültig" unless producer_cert.verify(intermediate_cert.public_key)
      errors << "Recipient-Zertifikat-Signatur ungültig" unless recipient_cert.verify(intermediate_cert.public_key)

      errors << "Root CA ist nicht selbstsigniert (Subject != Issuer)" unless root_cert.subject.to_s == root_cert.issuer.to_s
      errors << "Intermediate-CA-Issuer stimmt nicht mit Root-CA-Subject überein" unless intermediate_cert.issuer.to_s == root_cert.subject.to_s
      errors << "Producer-Issuer stimmt nicht mit Intermediate-CA-Subject überein" unless producer_cert.issuer.to_s == intermediate_cert.subject.to_s
      errors << "Recipient-Issuer stimmt nicht mit Intermediate-CA-Subject überein" unless recipient_cert.issuer.to_s == intermediate_cert.subject.to_s

      { "Root CA" => root_cert, "Intermediate CA" => intermediate_cert }.each do |label, cert|
        errors << "#{label}: basicConstraints fehlt oder ist nicht critical" unless critical_extension?(cert, "basicConstraints")
        errors << "#{label}: keyUsage fehlt oder ist nicht critical" unless critical_extension?(cert, "keyUsage")
      end
      { "Producer" => producer_cert, "Recipient" => recipient_cert }.each do |label, cert|
        errors << "#{label}: basicConstraints fehlt oder ist nicht critical" unless critical_extension?(cert, "basicConstraints")
        errors << "#{label}: keyUsage fehlt oder ist nicht critical" unless critical_extension?(cert, "keyUsage")
      end

      expected_constraints = {
        "Root CA" => [root_cert, "CA:TRUE", "pathlen:1"],
        "Intermediate CA" => [intermediate_cert, "CA:TRUE", "pathlen:0"],
        "Producer" => [producer_cert, "CA:FALSE", nil],
        "Recipient" => [recipient_cert, "CA:FALSE", nil]
      }
      expected_constraints.each do |label, (cert, ca_value, path_length)|
        value = extension_value(cert, "basicConstraints")
        errors << "#{label}: basicConstraints muss #{ca_value} enthalten" unless value&.include?(ca_value)
        errors << "#{label}: basicConstraints muss #{path_length} enthalten" if path_length && !value&.include?(path_length)
      end

      expected_key_usages = {
        "Root CA" => [root_cert, ["Certificate Sign", "CRL Sign"], []],
        "Intermediate CA" => [intermediate_cert, ["Certificate Sign", "CRL Sign"], []],
        "Producer" => [producer_cert, ["Digital Signature"], ["Certificate Sign", "Key Encipherment"]],
        "Recipient" => [recipient_cert, ["Key Encipherment"], ["Certificate Sign", "Digital Signature"]]
      }
      expected_key_usages.each do |label, (cert, required, prohibited)|
        value = extension_value(cert, "keyUsage").to_s
        required.each { |usage| errors << "#{label}: Key Usage #{usage} fehlt" unless value.include?(usage) }
        prohibited.each { |usage| errors << "#{label}: unzulässige Key Usage #{usage}" if value.include?(usage) }
      end

      { "Root CA" => root_cert, "Intermediate CA" => intermediate_cert, "Producer" => producer_cert, "Recipient" => recipient_cert }.each do |label, cert|
        key = cert.public_key
        errors << "#{label}: Public Key muss RSA-3072 sein" unless key.is_a?(OpenSSL::PKey::RSA) && key.n.num_bits == KEY_BITS
      end

      if producer_cert.public_key.to_der == recipient_cert.public_key.to_der
        errors << "Producer und Recipient müssen getrennte Schlüsselpaare verwenden"
      end

      { "Root CA" => root_cert, "Intermediate CA" => intermediate_cert, "Producer" => producer_cert, "Recipient" => recipient_cert }.each do |label, cert|
        errors << "#{label}-Zertifikat außerhalb der Gültigkeitsperiode" unless cert.not_before <= validation_time && validation_time <= cert.not_after
      end

      # T1 §2.5.3: Producer Certificate SHALL carry a SAN URI identical to
      # the responsible_organization.organization_id used in Package
      # Manifests signed with it.
      producer_sans = subject_alternative_name_uris(producer_cert)
      errors << "Producer-Zertifikat: Subject Alternative Name fehlt" if producer_sans.empty?
      unless producer_sans.include?(organization_id)
        errors << "Producer-Zertifikat: Subject Alternative Name (#{producer_sans.inspect}) enthält nicht die erwartete organization_id (#{organization_id})"
      end

      # T1 §2.5.4: Recipient Certificate SHALL carry a SAN URI identical to
      # the recipient.organization_id used in a KDM for that Recipient.
      recipient_sans = subject_alternative_name_uris(recipient_cert)
      errors << "Recipient-Zertifikat: Subject Alternative Name fehlt" if recipient_sans.empty?
      unless recipient_sans.include?(recipient_organization_id)
        errors << "Recipient-Zertifikat: Subject Alternative Name (#{recipient_sans.inspect}) enthält nicht die erwartete recipient_organization_id (#{recipient_organization_id})"
      end

      producer_chain = recipient_chain = nil

      if errors.empty?
        write_chain(output_dir, :producer, [producer_cert, intermediate_cert, root_cert])
        write_chain(output_dir, :recipient, [recipient_cert, intermediate_cert, root_cert])
        producer_chain = chain_path(output_dir, :producer)
        recipient_chain = chain_path(output_dir, :recipient)

        errors.concat(verify_chain_file_readable(producer_chain, 3))
        errors.concat(verify_chain_file_readable(recipient_chain, 3))
      end

      ChainValidation.new(valid: errors.empty?, errors: errors, producer_chain_path: producer_chain, recipient_chain_path: recipient_chain)
    end

    # Proves the chain export round-trips: re-reads the just-written PEM
    # bundle and parses each certificate block individually, rather than
    # trusting that write_chain produced something OpenSSL can consume.
    def self.verify_chain_file_readable(path, expected_count)
      return ["#{path} fehlt"] unless File.exist?(path)

      blocks = File.read(path).scan(/-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m)
      errors = []
      errors << "#{path}: erwartet #{expected_count} Zertifikate, gefunden #{blocks.size}" unless blocks.size == expected_count

      blocks.each_with_index do |block, index|
        OpenSSL::X509::Certificate.new(block)
      rescue OpenSSL::X509::CertificateError => e
        errors << "#{path}: Zertifikat ##{index + 1} nicht lesbar (#{e.message})"
      end

      errors
    end
    private_class_method :verify_chain_file_readable

    def self.critical_extension?(cert, oid)
      ext = cert.extensions.find { |e| e.oid == oid }
      !ext.nil? && ext.critical?
    end
    private_class_method :critical_extension?

    def self.extension_value(cert, oid)
      cert.extensions.find { |extension| extension.oid == oid }&.value
    end
    private_class_method :extension_value

    def self.subject_alternative_name_uris(cert)
      ext = cert.extensions.find { |e| e.oid == "subjectAltName" }
      return [] unless ext

      ext.value.split(",").map(&:strip).filter_map { |v| v.delete_prefix("URI:") if v.start_with?("URI:") }
    end
    private_class_method :subject_alternative_name_uris

    def self.base_certificate(key, subject, issuer, serial)
      cert = OpenSSL::X509::Certificate.new
      cert.version    = 2
      cert.serial     = serial
      cert.subject    = subject
      cert.issuer     = issuer
      cert.public_key = key
      cert.not_before = VALID_FROM
      cert.not_after  = VALID_FROM + (VALIDITY_DAYS * 24 * 60 * 60)
      cert
    end
    private_class_method :base_certificate

    def self.apply_ca_extensions(cert, issuer_cert, path_length:)
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate  = issuer_cert
      cert.add_extension ef.create_extension("subjectKeyIdentifier", "hash")
      # Self-signed (Root CA): authorityKeyIdentifier would only point back
      # at the certificate's own subjectKeyIdentifier - conventionally omitted.
      cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always") if cert.subject != cert.issuer
      cert.add_extension ef.create_extension("basicConstraints", "CA:TRUE,pathlen:#{path_length}", true)
      cert.add_extension ef.create_extension("keyUsage", "keyCertSign,cRLSign", true)
    end
    private_class_method :apply_ca_extensions

    def self.apply_leaf_extensions(cert, issuer_cert, key_usage:, extended_key_usage:, subject_alternative_name: nil)
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate  = issuer_cert
      cert.add_extension ef.create_extension("subjectKeyIdentifier", "hash")
      cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always") if cert.subject != cert.issuer
      cert.add_extension ef.create_extension("basicConstraints", "CA:FALSE", true)
      cert.add_extension ef.create_extension("keyUsage", key_usage, true)
      cert.add_extension ef.create_extension("extendedKeyUsage", extended_key_usage) if extended_key_usage
      # T1 §2.5.4: required on the Recipient Certificate, unused otherwise.
      cert.add_extension ef.create_extension("subjectAltName", subject_alternative_name) if subject_alternative_name
    end
    private_class_method :apply_leaf_extensions

    def self.write(output_dir, role, cert, key)
      FileUtils.mkdir_p(role_dir(output_dir, role))

      crt = crt_path(output_dir, role)
      key_p = key_path(output_dir, role)
      cer = cer_path(output_dir, role)

      File.write(crt, cert.to_pem)
      File.write(key_p, key.to_pem)
      File.binwrite(cer, cert.to_der)
      File.write(sha1_path(output_dir, role), "#{fingerprint_line('SHA1', thumbprint_sha1(cert))}\n")
      File.write(sha256_path(output_dir, role), "#{fingerprint_line('SHA256', thumbprint_sha256(cert))}\n")
      # Human-readable dump, equivalent to `openssl x509 -in <crt> -text -noout`.
      File.write(text_path(output_dir, role), cert.to_text)

      Result.new(
        certificate: cert, private_key: key,
        crt_path: crt, key_path: key_p, cer_path: cer,
        thumbprint_sha1: thumbprint_sha1(cert), thumbprint_sha256: thumbprint_sha256(cert)
      )
    end
    private_class_method :write

    def self.write_chain(output_dir, role, certs_leaf_to_root)
      File.write(chain_path(output_dir, role), certs_leaf_to_root.map(&:to_pem).join)
    end
    private_class_method :write_chain

    def self.read(output_dir, role)
      crt = crt_path(output_dir, role)
      key_p = key_path(output_dir, role)
      raise "#{crt} fehlt - der vorausgehende T1-Schritt wurde nicht ausgeführt" unless File.exist?(crt)

      cert = OpenSSL::X509::Certificate.new(File.read(crt))
      key  = File.exist?(key_p) ? OpenSSL::PKey.read(File.read(key_p)) : nil
      [cert, key]
    end
    private_class_method :read
  end
end
