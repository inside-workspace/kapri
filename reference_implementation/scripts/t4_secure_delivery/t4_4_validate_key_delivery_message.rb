#!/usr/bin/env ruby
# T4.4 - Validate KAP-KDM
#
# Prüft kdm.json strukturell gegen S4 - Key Delivery Message Schema,
# verifiziert die digitale Signatur, die Zertifikatskette anhand der in
# signature.certificate_chain eingebetteten Zertifikate (SC1 §4.13) sowie
# das Recipient Certificate und dessen Korrespondenz zu recipient (S4
# §3.2.6) - keine externe PKI nötig. Voraussetzung: T4.3.
#
#   ruby reference_implementation/scripts/t4_secure_delivery/t4_4_validate_key_delivery_message.rb [package-verzeichnis]

require_relative "../../lib/kapri/secure_delivery"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR

result = Kapri::SecureDelivery.validate_kdm(output_dir: output_dir)

puts "T4.4 Validate KAP-KDM: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
