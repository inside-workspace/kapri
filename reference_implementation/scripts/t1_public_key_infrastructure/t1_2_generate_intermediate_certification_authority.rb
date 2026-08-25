#!/usr/bin/env ruby
# T1.2 - Generate Intermediate Certification Authority
#
# Erzeugt die Intermediate CA, signiert von der Root CA. Voraussetzung: T1.1
# wurde zuvor ausgeführt. Voraussetzung für T1.3 und T1.4.
#
#   ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_2_generate_intermediate_certification_authority.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/pki"

DEFAULT_OUTPUT_DIR = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PKI.generate_intermediate_ca(output_dir: output_dir)

puts "T1.2 Generate Intermediate Certification Authority: OK"
puts "  Zertifikat (PEM): #{result.crt_path}"
puts "  Zertifikat (DER): #{result.cer_path}"
puts "  Private Key:      #{result.key_path}"
puts "  Thumbprint SHA1:   #{result.thumbprint_sha1}"
puts "  Thumbprint SHA256: #{result.thumbprint_sha256}"
