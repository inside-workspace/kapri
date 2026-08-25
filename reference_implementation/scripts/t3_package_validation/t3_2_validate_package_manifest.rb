#!/usr/bin/env ruby
# T3.2 - Validate Package Manifest
#
# Prüft manifest.json strukturell gegen S1 - Package Manifest Schema
# (Pflichtfelder, Typen, Cardinalitäten). Voraussetzung: T3.1.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_2_validate_package_manifest.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_manifest(output_dir: output_dir)

puts "T3.2 Validate Package Manifest: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
