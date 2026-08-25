#!/usr/bin/env ruby
# T3.8 - Validate File Hashes
#
# Berechnet für jede vorhandene Package File den SHA-256-Hash neu und
# vergleicht ihn (sowie die Dateigröße) mit den Angaben in der Packing List.
# Voraussetzung: T3.7.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_8_validate_file_hashes.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_file_hashes(output_dir: output_dir)

puts "T3.8 Validate File Hashes: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
