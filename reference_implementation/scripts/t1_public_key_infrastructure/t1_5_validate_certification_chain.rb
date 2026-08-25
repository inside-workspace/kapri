#!/usr/bin/env ruby
# T1.5 - Validate Certification Chain
#
# Prüft, dass Producer- und Recipient-Zertifikat über die Intermediate CA bis
# zur Root CA verifizieren, Issuer/Subject-Bindungen korrekt sind und alle
# vier Zertifikate innerhalb ihrer Gültigkeitsperiode liegen. Voraussetzung:
# T1.1-T1.4 wurden zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_5_validate_certification_chain.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/pki"

DEFAULT_OUTPUT_DIR = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
validation_time = Kapri::PKI::VALID_FROM + (24 * 60 * 60)
result = Kapri::PKI.validate_certification_chain(output_dir: output_dir, validation_time: validation_time)

if result.valid
  puts "T1.5 Validate Certification Chain: OK"
else
  puts "T1.5 Validate Certification Chain: FEHLER"
  result.errors.each { |e| puts "  - #{e}" }
end

exit(result.valid ? 0 : 1)
