require "openssl"
require "base64"

module Kapri
  # SHA-256 digests, Base64url-encoded without padding (RFC 4648 SS5).
  #
  # The Reference Cryptographic Profile requires Base64url without padding
  # for hashes, signatures and Encrypted File Keys.
  module Hasher
    ALGORITHM = "SHA-256".freeze

    def self.base64url(raw_bytes) = Base64.urlsafe_encode64(raw_bytes, padding: false)

    def self.decode_base64url(str) = Base64.urlsafe_decode64(str)

    def self.sha256(bytes) = base64url(OpenSSL::Digest::SHA256.digest(bytes))

    def self.thumbprint(x509_certificate) = base64url(OpenSSL::Digest::SHA256.digest(x509_certificate.to_der))

    # Reference-implementation convention for Certificate Reference (SC1
    # SS4.13 leaves the concrete form to the referencing schema
    # specification; S1/S4 only constrain "certificate_id" to be a URI).
    # Shared by T2 (signing) and T3 (signature validation) so both sides
    # resolve to the same identifier for the same certificate.
    def self.certificate_id(x509_certificate) = "urn:kap:certificate:sha256:#{thumbprint(x509_certificate)}"
  end
end
