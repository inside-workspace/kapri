#!/usr/bin/env ruby
# T2.4 - Generate Composition
#
# Erzeugt eine Composition, die alle in der Packing List (T2.3) enthaltenen
# Files referenziert. Voraussetzung: T2.3 wurde zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_4_generate_composition.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageGeneration.generate_composition(output_dir: output_dir)

puts "T2.4 Generate Composition: OK"
puts "  #{result.path}"
puts "  composition_id: #{result.composition['composition_id']}"
