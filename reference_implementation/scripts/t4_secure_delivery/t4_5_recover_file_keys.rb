#!/usr/bin/env ruby
# T4.5 - Recover File Keys
#
# Konsumentenseitig: entpackt jeden Encrypted File Key aus kdm.json mit dem
# privaten Schlüssel des Recipient (RSA-OAEP-256). Voraussetzung: T4.4 erfolgreich.
#
#   ruby reference_implementation/scripts/t4_secure_delivery/t4_5_recover_file_keys.rb [package-verzeichnis] [pki-verzeichnis]

require_relative "../../lib/kapri/secure_delivery"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)
DEFAULT_PKI_DIR    = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
pki_dir    = ARGV[1] || DEFAULT_PKI_DIR

recovered = Kapri::SecureDelivery.recover_file_keys(output_dir: output_dir, pki_dir: pki_dir)

puts "T4.5 Recover File Keys: OK"
recovered.each_key { |key_id| puts "  key_id: #{key_id}" }
