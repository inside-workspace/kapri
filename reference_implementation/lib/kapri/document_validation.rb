require "json"
require "time"
require "openssl"
require "base64"
require_relative "hasher"

module Kapri
  # Shared structural-validation primitives, used by both T3 (Package
  # Validation) and T4 (Secure Delivery / KDM validation): common data
  # type checks from SC1 and small JSON-loading helpers. Not a generic
  # JSON Schema engine - see package_validation.rb for why.
  module DocumentValidation
    module_function

    # Lightweight RFC 3986 approximation (scheme":" prefix) rather than a
    # full URI parser/validator - sufficient to distinguish "looks like a
    # URI" from "clearly not one" for conformance purposes.
    def uri?(value) = present_string?(value) && value.match?(/\A[a-zA-Z][a-zA-Z0-9+\-.]*:/)

    def present_string?(value) = value.is_a?(String) && !value.empty?

    def value_at(value, *keys)
      keys.reduce(value) do |current, key|
        return nil unless current.is_a?(Hash)
        current[key]
      end
    end

    # SC1 SS4.6/SS6.4 (File Path): SHALL be relative, SHALL NOT contain path
    # traversal segments ("../"), SHALL identify a file within the Package
    # archive. Syntactic check only - resolve_within below is the
    # authoritative check actually used before touching the filesystem.
    def safe_relative_path?(path)
      return false unless present_string?(path)
      return false if path.start_with?("/")

      segments = path.split("/")
      return false if segments.any? { |segment| segment == ".." || segment.empty? }

      true
    end

    # Resolves `path` against output_dir and returns the resolved absolute
    # path only if it both looks like a safe relative path AND actually
    # resolves to a location inside output_dir (defense in depth beyond the
    # syntactic ".." check - catches anything the segment check might miss).
    # Returns nil for anything unsafe; callers MUST treat nil as "do not
    # touch the filesystem with this path".
    def resolve_within(output_dir, path)
      return nil unless safe_relative_path?(path)

      base = File.expand_path(output_dir)
      full = File.expand_path(File.join(base, path))
      return nil unless full == base || full.start_with?(base + File::SEPARATOR)

      full
    end

    def timestamp?(value)
      return false unless present_string?(value)

      Time.iso8601(value)
      true
    rescue ArgumentError
      false
    end

    def utc_timestamp?(value)
      return false unless timestamp?(value)

      Time.iso8601(value).utc_offset.zero?
    end

    def load_json(path)
      return [nil, ["#{path} fehlt"]] unless File.exist?(path)

      [JSON.parse(File.read(path)), []]
    rescue JSON::ParserError => e
      [nil, ["#{path} ist kein gültiges JSON: #{e.message}"]]
    end

    def validate_organization(org, field)
      return ["#{field} fehlt oder ist kein Objekt"] unless org.is_a?(Hash)

      errors = []
      errors << "#{field}.organization_id fehlt oder ist keine gültige URI" unless uri?(org["organization_id"])
      errors << "#{field}.name fehlt" unless present_string?(org["name"])
      errors
    end

    def validate_document_reference(dr, field)
      return ["#{field} fehlt oder ist kein Objekt"] unless dr.is_a?(Hash)

      errors = []
      errors << "#{field}.document_id fehlt oder ist keine gültige URI" unless uri?(dr["document_id"])
      errors << "#{field}.hash_algorithm fehlt" unless present_string?(dr["hash_algorithm"])
      errors << "#{field}.hash fehlt" unless present_string?(dr["hash"])
      errors
    end

    # SC1 SS4.12 Signature / SS4.13 Certificate Reference. Each
    # certificate_chain entry SHALL be a self-contained Certificate
    # Reference (certificate_id, issuer, serial_number, certificate) - no
    # external PKI lookup required to validate the signature.
    def validate_signature_structure(sig)
      return ["signature fehlt oder ist kein Objekt"] unless sig.is_a?(Hash)

      errors = []
      errors << "signature.algorithm muss 'PS256' sein" unless sig["algorithm"] == "PS256"

      chain = sig["certificate_chain"]
      if chain.is_a?(Array) && !chain.empty?
        chain.each_with_index { |c, i| errors.concat(validate_certificate_reference(c, "signature.certificate_chain[#{i}]")) }
      else
        errors << "signature.certificate_chain fehlt oder ist leer"
      end

      errors << "signature.signature_value ist kein gültiger Base64url-Wert ohne Padding mit 384 Oktetten" unless base64url?(sig["signature_value"], decoded_length: 384)
      errors
    end

    def validate_certificate_reference(c, field)
      return ["#{field} ist kein Objekt"] unless c.is_a?(Hash)

      errors = []
      errors << "#{field}.certificate_id fehlt oder ist keine gültige URI" unless uri?(c["certificate_id"])
      errors << "#{field}.subject fehlt" unless present_string?(c["subject"])
      errors << "#{field}.issuer fehlt" unless present_string?(c["issuer"])
      errors << "#{field}.serial_number fehlt" unless present_string?(c["serial_number"])
      errors << "#{field}.certificate fehlt oder ist kein gültiges Base64-DER-Zertifikat" if parse_certificate(c["certificate"]).nil?
      cert = parse_certificate(c["certificate"])
      if cert
        expected_subject = cert.subject.to_s(OpenSSL::X509::Name::RFC2253)
        expected_issuer = cert.issuer.to_s(OpenSSL::X509::Name::RFC2253)
        errors << "#{field}.subject entspricht nicht dem eingebetteten Zertifikat" unless c["subject"] == expected_subject
        errors << "#{field}.issuer entspricht nicht dem eingebetteten Zertifikat" unless c["issuer"] == expected_issuer
        errors << "#{field}.serial_number entspricht nicht dem eingebetteten Zertifikat" unless c["serial_number"] == cert.serial.to_s
      end
      errors
    end

    def base64url?(value, decoded_length: nil)
      return false unless present_string?(value)
      return false unless value.match?(/\A[A-Za-z0-9_-]+\z/)
      return false if value.include?("=")

      decoded = Base64.urlsafe_decode64(value)
      decoded_length.nil? || decoded.bytesize == decoded_length
    rescue ArgumentError
      false
    end

    def sha256_value?(value)
      base64url?(value, decoded_length: 32)
    end

    # Decodes a Base64-DER certificate (SC1 SS4.13 "certificate" property:
    # standard alphabet, with padding). strict_decode64 rather than the
    # lenient decode64, so malformed Base64 is rejected here instead of
    # silently truncated/reinterpreted.
    def parse_certificate(base64_der)
      return nil unless present_string?(base64_der)

      OpenSSL::X509::Certificate.new(Base64.strict_decode64(base64_der))
    rescue OpenSSL::X509::CertificateError, ArgumentError
      nil
    end

    # Parses every certificate_chain entry's embedded "certificate". Returns
    # [certs, errors] - certs is nil if any entry failed to parse (structural
    # validity is expected to have been checked separately beforehand).
    def parse_certificate_chain(chain)
      return [nil, ["certificate_chain fehlt oder ist leer"]] unless chain.is_a?(Array) && !chain.empty?

      certs = chain.map { |c| c.is_a?(Hash) ? parse_certificate(c["certificate"]) : nil }
      return [nil, ["certificate_chain enthält ein nicht dekodierbares Zertifikat"]] if certs.any?(&:nil?)

      [certs, []]
    end

    # SC1 SS4.13 Validation: leaf-to-root order, each certificate issued by
    # the one following it, last certificate self-issued. Purely structural/
    # cryptographic - does not decide whether the root is trusted (that
    # remains a Consumer Decision per S0 SS7.2, out of scope here).
    def validate_chain_integrity(certs)
      errors = []

      certs.each_cons(2) do |cert, issuer_cert|
        errors << "Zertifikat '#{cert.subject}' ist nicht von '#{issuer_cert.subject}' ausgestellt (Issuer/Subject stimmen nicht überein)" unless cert.issuer.to_s == issuer_cert.subject.to_s
        errors << "Signatur von Zertifikat '#{cert.subject}' ist gegen '#{issuer_cert.subject}' ungültig" unless verify_certificate(cert, issuer_cert.public_key)
      end

      root = certs.last
      errors << "Root-Zertifikat '#{root.subject}' ist nicht selbstsigniert (Subject != Issuer)" unless root.subject.to_s == root.issuer.to_s
      errors << "Root-Zertifikat '#{root.subject}' hat eine ungültige Selbstsignatur" unless verify_certificate(root, root.public_key)

      errors
    end

    def validate_reference_chain_profile(certs, leaf_role: :producer)
      errors = []
      errors << "Reference-Zertifikatskette muss genau Leaf, Intermediate und Root enthalten" unless certs.size == 3

      certs.each_with_index do |cert, index|
        errors << "certificate_chain[#{index}] muss einen RSA-3072 Public Key enthalten" unless rsa3072?(cert.public_key)
      end

      return errors unless certs.size == 3

      leaf, intermediate, root = certs
      errors.concat(validate_ca_profile(root, "Root CA", path_length: 1))
      errors.concat(validate_ca_profile(intermediate, "Intermediate CA", path_length: 0))
      errors.concat(validate_leaf_profile(leaf, leaf_role.to_s.capitalize, required_usage: "Digital Signature", prohibited_usage: "Key Encipherment"))
      errors
    end

    def validate_recipient_certificate_profile(cert)
      errors = []
      errors << "Recipient Certificate muss einen RSA-3072 Public Key enthalten" unless rsa3072?(cert.public_key)
      errors.concat(validate_leaf_profile(cert, "Recipient", required_usage: "Key Encipherment", prohibited_usage: "Digital Signature"))
      errors
    end

    def rsa3072?(key)
      key.is_a?(OpenSSL::PKey::RSA) && key.n.num_bits == 3072
    end

    def validate_ca_profile(cert, label, path_length:)
      errors = []
      constraints = extension_value(cert, "basicConstraints")
      usage = extension_value(cert, "keyUsage")
      errors << "#{label}: basicConstraints muss critical CA:TRUE, pathlen:#{path_length} sein" unless critical_extension?(cert, "basicConstraints") && constraints&.include?("CA:TRUE") && constraints&.include?("pathlen:#{path_length}")
      errors << "#{label}: keyUsage muss critical Certificate Sign und CRL Sign erlauben" unless critical_extension?(cert, "keyUsage") && usage&.include?("Certificate Sign") && usage&.include?("CRL Sign")
      errors
    end
    private_class_method :validate_ca_profile

    def validate_leaf_profile(cert, label, required_usage:, prohibited_usage:)
      errors = []
      constraints = extension_value(cert, "basicConstraints")
      usage = extension_value(cert, "keyUsage")
      errors << "#{label}: basicConstraints muss critical CA:FALSE sein" unless critical_extension?(cert, "basicConstraints") && constraints&.include?("CA:FALSE")
      errors << "#{label}: keyUsage muss critical #{required_usage} erlauben" unless critical_extension?(cert, "keyUsage") && usage&.include?(required_usage)
      errors << "#{label}: keyUsage darf #{prohibited_usage} nicht erlauben" if usage&.include?(prohibited_usage)
      errors << "#{label}: keyUsage darf Certificate Sign nicht erlauben" if usage&.include?("Certificate Sign")
      errors
    end
    private_class_method :validate_leaf_profile

    def extension_value(cert, oid)
      cert.extensions.find { |extension| extension.oid == oid }&.value
    end
    private_class_method :extension_value

    def critical_extension?(cert, oid)
      extension = cert.extensions.find { |candidate| candidate.oid == oid }
      extension && extension.critical?
    end
    private_class_method :critical_extension?

    def verify_certificate(cert, public_key)
      cert.verify(public_key)
    rescue OpenSSL::X509::CertificateError
      false
    end

    # T1 SS2.5.1-2.5.4: every certificate in a chain SHALL be valid at `at`
    # (the Package Manifest's or KAP-KDM's published_at/signing timestamp) -
    # not just structurally well-formed and correctly signed.
    def validate_chain_validity_period(certs, at:)
      certs.filter_map do |cert|
        next if cert.not_before <= at && at <= cert.not_after

        "Zertifikat '#{cert.subject}' war zum Zeitpunkt #{at.utc.iso8601} nicht gültig " \
          "(gültig #{cert.not_before.utc.iso8601} bis #{cert.not_after.utc.iso8601})"
      end
    end

    # SC1 SS4.13 / T1 SS2.5.4: uniformResourceIdentifier values of a
    # certificate's Subject Alternative Name extension.
    def subject_alternative_name_uris(cert)
      ext = cert.extensions.find { |e| e.oid == "subjectAltName" }
      return [] unless ext

      ext.value.split(",").map(&:strip).filter_map { |v| v.delete_prefix("URI:") if v.start_with?("URI:") }
    end
  end
end
