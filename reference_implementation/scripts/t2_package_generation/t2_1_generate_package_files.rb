#!/usr/bin/env ruby
# T2.1 - Generate Package Files
#
# Erzeugt die physischen Package Files (Beispiel-Payload) des KAPRI
# Referenzpakets und berechnet deren Hash. Verschlüsselung ist ein
# eigener Schritt, siehe T2.2.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_1_generate_package_files.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR

result = Kapri::PackageGeneration.generate_package_files(output_dir: output_dir)

puts "T2.1 Generate Package Files: OK"
result.files.each do |file|
  puts "  #{file['path']} (#{file['size']} bytes, #{file['hash_algorithm']}: #{file['hash']})"
end
