#!/usr/bin/env ruby
# T3.9 - Validate Cross References
#
# Prüft die Konsistenz zwischen den Package-Dokumenten: manifest.packing_list
# .hash gegen packing-list.json, manifest.compositions[].hash gegen die
# jeweilige Composition-Datei, und dass jede von einer Composition
# referenzierte file_id in der Packing List existiert.
# Voraussetzung: T3.1.
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_9_validate_cross_references.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageValidation.validate_cross_references(output_dir: output_dir)

puts "T3.9 Validate Cross References: #{result.valid ? 'OK' : 'FEHLER'}"
result.errors.each { |e| puts "  - #{e}" }
exit(result.valid ? 0 : 1)
