#!/usr/bin/env ruby
# T3.1 - Open Package
#
# Prüft, dass ein Package unter dem Zielverzeichnis vorliegt: manifest.json
# ist vorhanden und gültiges JSON, packing-list.json ist vorhanden, und
# mindestens eine Composition existiert unter compositions/.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_1_open_package.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_package_structure(output_dir: output_dir)

puts "T3.1 Open Package: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
