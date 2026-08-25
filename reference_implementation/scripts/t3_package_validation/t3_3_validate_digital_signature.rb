#!/usr/bin/env ruby
# T3.3 - Validate Digital Signature
#
# Verifiziert die Signatur des Package Manifest gegen dessen kanonische
# Repräsentation (RFC 8785, ohne "signature"), unter Verwendung des in
# signature.certificate_chain[0] eingebetteten Zertifikats (SC1 §4.13) -
# keine externe PKI nötig. Voraussetzung: T3.1.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_3_validate_digital_signature.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR

result = Kapri::PackageValidation.validate_signature(output_dir: output_dir)

puts "T3.3 Validate Digital Signature: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
