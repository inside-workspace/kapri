#!/usr/bin/env ruby
# T3.5 - Validate Packing List
#
# Prüft packing-list.json strukturell gegen S2 - Packing List Schema
# (Pflichtfelder, Typen, Eindeutigkeit von file_id und path).
# Voraussetzung: T3.1.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_5_validate_packing_list.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_packing_list(output_dir: output_dir)

puts "T3.5 Validate Packing List: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
