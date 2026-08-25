#!/usr/bin/env ruby
# T1.1 - Generate Root Certification Authority
#
# Erzeugt die selbstsignierte KAPRI Reference Root CA und schreibt Zertifikat
# + privaten Schlüssel ins Ziel-Verzeichnis (Default: certificates/ im
# KAPRI-Docs-Referenzpaket). Voraussetzung für T1.2.
#
#   ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_1_generate_root_certification_authority.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/pki"

DEFAULT_OUTPUT_DIR = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PKI.generate_root_ca(output_dir: output_dir)

puts "T1.1 Generate Root Certification Authority: OK"
puts "  Zertifikat (PEM): #{result.crt_path}"
puts "  Zertifikat (DER): #{result.cer_path}"
puts "  Private Key:      #{result.key_path}"
puts "  Thumbprint SHA1:   #{result.thumbprint_sha1}"
puts "  Thumbprint SHA256: #{result.thumbprint_sha256}"
