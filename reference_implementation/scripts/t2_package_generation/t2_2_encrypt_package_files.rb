#!/usr/bin/env ruby
# T2.2 - Encrypt Package Files, if required
#
# Verschlüsselt jede in T2.1 erzeugte Package File AES-256-GCM (T1
# Reference Cryptographic Profile) und generiert je Datei einen File Key
# samt Key Identifier. Nicht anwendbar, wenn das Referenzpaket keine
# verschlüsselten Package Files enthalten soll - dieser Schritt wird dann
# einfach ausgelassen. Voraussetzung: T2.1.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_2_encrypt_package_files.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR

result = Kapri::PackageGeneration.encrypt_package_files(output_dir: output_dir)

puts "T2.2 Encrypt Package Files: OK"
result.files.each do |file|
  puts "  #{file['path']} (#{file['size']} bytes, #{file['hash_algorithm']}: #{file['hash']})"
  puts "    key_id: #{file['key_id']}" if file["key_id"]
end
