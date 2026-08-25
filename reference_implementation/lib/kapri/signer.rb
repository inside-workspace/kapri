require "openssl"
require "base64"
require_relative "canonicalization"
require_relative "hasher"

module Kapri
  # Signing per S1 SS3.2.14 / S4 SS3.2.7: canonicalize the document
  # *without* its "signature" property (RFC 8785 / JCS), sign the
  # resulting UTF-8 bytes, then attach the signature object. SC1 SS4.12
  # fixes the signature shape to exactly {algorithm, certificate_chain,
  # signature_value} and explicitly excludes "signature" itself from the
  # canonical representation - so, unlike a placeholder-then-replace
  # scheme, the canonicalized bytes never contain a "signature" key at all.
  #
  # Algorithm: PS256 (RSASSA-PSS, SHA-256, MGF1-SHA256, 32-octet salt) per
  # RFC 7518, matching the Cryptographic Profile defined by T1 SS2.4.2. The
  # Producer role - the sole signer Signer is ever used with - holds an
  # RSA-3072 key (T1 SS2.5.3).
  module Signer
    ALGORITHM = "PS256".freeze
    PSS_SALT_LENGTH = 32
    PSS_MGF1_HASH = "SHA256"

    # document: Hash without a "signature" key.
    # certificate_chain: Array of OpenSSL::X509::Certificate, leaf-to-root
    # order. Each is embedded as a full SC1 SS4.13 Certificate Reference
    # (self-contained - no external PKI lookup required to validate).
    # Returns the complete document including "signature".
    def self.sign_document(document, private_key:, certificate_chain:)
      canonical_bytes = Canonicalization.serialize(document).b
      raw_signature = private_key.sign_pss(
        OpenSSL::Digest::SHA256.new, canonical_bytes,
        salt_length: PSS_SALT_LENGTH, mgf1_hash: PSS_MGF1_HASH
      )

      signature = {
        "algorithm" => ALGORITHM,
        "certificate_chain" => certificate_chain.map { |cert| certificate_chain_entry(cert) },
        "signature_value" => Hasher.base64url(raw_signature)
      }

      document.merge("signature" => signature)
    end

    # SC1 SS4.13 Certificate Reference. "subject" and "issuer" are
    # normatively RFC 4514, which obsoletes and is string-format-compatible
    # with RFC 2253 for every DN this reference PKI produces (single-valued
    # RDNs, no leading space/'#' or trailing space in any attribute value -
    # the cases where RFC 4514 tightens RFC 2253's escaping). OpenSSL::X509::Name
    # has no native RFC 4514 formatter, so RFC2253 is used as the closest
    # available approximation.
    def self.certificate_chain_entry(cert)
      {
        "certificate_id" => Hasher.certificate_id(cert),
        "subject"        => cert.subject.to_s(OpenSSL::X509::Name::RFC2253),
        "issuer"         => cert.issuer.to_s(OpenSSL::X509::Name::RFC2253),
        "serial_number"  => cert.serial.to_s,
        "certificate"    => Base64.strict_encode64(cert.to_der)
      }
    end

    # Returns true/false. Does not raise on an invalid signature, only on a
    # structurally missing "signature" object.
    def self.verify_document(signed_document, public_key)
      signature = signed_document.fetch("signature")
      return false unless signature["algorithm"] == ALGORITHM
      signature_value = signature.fetch("signature_value")

      unsigned_document = signed_document.reject { |k, _| k == "signature" }
      canonical_bytes = Canonicalization.serialize(unsigned_document).b

      public_key.verify_pss(
        OpenSSL::Digest::SHA256.new, Hasher.decode_base64url(signature_value), canonical_bytes,
        salt_length: PSS_SALT_LENGTH, mgf1_hash: PSS_MGF1_HASH
      )
    rescue OpenSSL::PKey::PKeyError, ArgumentError, KeyError
      false
    end
  end
end
