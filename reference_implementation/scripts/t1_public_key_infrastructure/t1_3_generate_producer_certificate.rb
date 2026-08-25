#!/usr/bin/env ruby
# T1.3 - Generate Producer Certificate
#
# Erzeugt das Producer-Zertifikat (signiert Package Manifests und Key
# Delivery Messages), signiert von der Intermediate CA. Voraussetzung: T1.2
# wurde zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_3_generate_producer_certificate.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/pki"

DEFAULT_OUTPUT_DIR = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PKI.generate_producer_certificate(output_dir: output_dir)

puts "T1.3 Generate Producer Certificate: OK"
puts "  Zertifikat (PEM): #{result.crt_path}"
puts "  Zertifikat (DER): #{result.cer_path}"
puts "  Private Key:      #{result.key_path}"
puts "  Thumbprint SHA1:   #{result.thumbprint_sha1}"
puts "  Thumbprint SHA256: #{result.thumbprint_sha256}"
