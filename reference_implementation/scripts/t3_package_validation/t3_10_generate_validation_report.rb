#!/usr/bin/env ruby
# T3.10 - Generate Validation Report
#
# Führt T3.1-T3.9 vollständig aus (unabhängig davon, ob einzelne Kategorien
# fehlschlagen) und schreibt einen Report mit dem Ergebnis jeder einzelnen
# Kategorie sowie einem Gesamtergebnis - statt nur eines einzelnen
# VALID/INVALID (siehe Ergänzung in specification/15: T3.md).
#
#   ruby reference_implementation/scripts/t3_package_validation/t3_10_generate_validation_report.rb [package-verzeichnis]

require_relative "../../lib/kapri/package_validation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR

report = Kapri::PackageValidation.generate_report(output_dir: output_dir)

puts "T3.10 Generate Validation Report:"
report.categories.each do |category|
  puts "  #{category.name.ljust(18)} #{category.valid ? 'valid' : 'invalid'}"
  category.errors.each { |e| puts "    - #{e}" }
end
puts "  #{'Overall Result'.ljust(18)} #{report.valid ? 'VALID' : 'INVALID'}"
puts "  -> #{Kapri::Workspace.report_path(output_dir)}"

exit(report.valid ? 0 : 1)
