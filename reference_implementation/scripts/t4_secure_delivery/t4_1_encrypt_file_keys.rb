#!/usr/bin/env ruby
# T4.1 - Encrypt File Keys for Recipient
#
# Verpackt jeden File Key, den T2.2 beim Verschlüsseln der Package Files
# erzeugt hat, für den Recipient aus der T1-Referenz-PKI (RSA-OAEP-256).
# Voraussetzung: T2.2, T3 erfolgreich, T1.1-T1.4.
#
#   ruby reference_implementation/scripts/t4_secure_delivery/t4_1_encrypt_file_keys.rb [package-verzeichnis] [pki-verzeichnis]

require_relative "../../lib/kapri/secure_delivery"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)
DEFAULT_PKI_DIR    = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
pki_dir    = ARGV[1] || DEFAULT_PKI_DIR

key_entries = Kapri::SecureDelivery.encrypt_file_keys(output_dir: output_dir, pki_dir: pki_dir)

puts "T4.1 Encrypt File Keys for Recipient: OK"
key_entries.each { |e| puts "  key_id: #{e['key_id']}" }
