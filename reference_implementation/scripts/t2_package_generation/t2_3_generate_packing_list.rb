#!/usr/bin/env ruby
# T2.3 - Generate Packing List
#
# Erzeugt die Packing List aus den in T2.1/T2.2 generierten Package Files.
# Voraussetzung: T2.1 (und, falls verschlüsselt werden soll, T2.2) wurden
# zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_3_generate_packing_list.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageGeneration.generate_packing_list(output_dir: output_dir)

puts "T2.3 Generate Packing List: OK"
puts "  #{result.path}"
puts "  packing_list_id: #{result.packing_list['packing_list_id']}"
