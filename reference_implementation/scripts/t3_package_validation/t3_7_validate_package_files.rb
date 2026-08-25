#!/usr/bin/env ruby
# T3.7 - Validate Package Files
#
# Prüft, dass jede in der Packing List referenzierte Datei physisch im
# Package-Verzeichnis existiert. Voraussetzung: T3.5.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_7_validate_package_files.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_package_files(output_dir: output_dir)

puts "T3.7 Validate Package Files: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
