#!/usr/bin/env ruby
# T2.5 - Generate Package Manifest
#
# Erzeugt den (noch unsignierten) Package Manifest, der auf die Packing List
# (T2.3) und alle vorhandenen Compositions (T2.4) verweist.
# Voraussetzung: T2.3 und T2.4 wurden zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_5_generate_package_manifest.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageGeneration.generate_manifest(output_dir: output_dir)

puts "T2.5 Generate Package Manifest: OK"
puts "  #{result.path} (unsigniert - siehe T2.7)"
puts "  package_id: #{result.manifest['package_id']}"
