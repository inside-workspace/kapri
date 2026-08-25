#!/usr/bin/env ruby
# T3.6 - Validate Composition
#
# Prüft jede Composition unter compositions/ strukturell gegen S3 -
# Composition Schema (Pflichtfelder, Eindeutigkeit von item_id/relation_id,
# Gültigkeit der Relation-Referenzen). Der Abgleich von Composition file_ids
# gegen die Packing List erfolgt in T3.9 (Cross References).
# Voraussetzung: T3.1.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_6_validate_composition.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_composition(output_dir: output_dir)

puts "T3.6 Validate Composition: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
