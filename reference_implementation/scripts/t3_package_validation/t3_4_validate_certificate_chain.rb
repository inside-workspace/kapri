#!/usr/bin/env ruby
# T3.4 - Validate Certificate Chain
#
# Validiert die in signature.certificate_chain des Package Manifest
# eingebettete Zertifikatskette (SC1 §4.13: leaf-to-root, jedes Zertifikat
# vom nächsten ausgestellt, Root selbstsigniert) - unabhängig von der
# lokalen Referenz-PKI, die T1.5 testet. Voraussetzung: T3.1.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_4_validate_certificate_chain.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_certificate_chain(output_dir: output_dir)

puts "T3.4 Validate Certificate Chain: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
