#!/usr/bin/env ruby
# T4.6 - Decrypt Package Files
#
# Konsumentenseitig: entschlüsselt jede Package File, für die T4.5 einen
# File Key wiederhergestellt hat (AES-256-GCM), und schreibt den Klartext
# nach <package-verzeichnis>/decrypted/<path>. Voraussetzung: T4.5.
#
#   ruby reference_implementation/scripts/t4_secure_delivery/t4_6_decrypt_package_files.rb [package-verzeichnis]

require_relative "../../lib/kapri/secure_delivery"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
decrypted = Kapri::SecureDelivery.decrypt_package_files(output_dir: output_dir)

puts "T4.6 Decrypt Package Files: OK"
decrypted.each { |d| puts "  #{d['path']} -> #{d['destination']} (#{d['size']} bytes)" }
