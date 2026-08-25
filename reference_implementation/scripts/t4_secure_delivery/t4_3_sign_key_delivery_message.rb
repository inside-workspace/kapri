#!/usr/bin/env ruby
# T4.3 - Sign KAP-KDM
#
# Signiert die KAP-KDM (T4.2) mit dem Producer-Zertifikat aus der
# T1-Referenz-PKI und schreibt kdm.json. Voraussetzung: T4.2, T1.1-T1.4.
#
#   ruby reference_implementation/scripts/t4_secure_delivery/t4_3_sign_key_delivery_message.rb [package-verzeichnis] [pki-verzeichnis]

require_relative "../../lib/kapri/secure_delivery"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)
DEFAULT_PKI_DIR    = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
pki_dir    = ARGV[1] || DEFAULT_PKI_DIR

kdm = Kapri::SecureDelivery.sign_kdm(output_dir: output_dir, pki_dir: pki_dir)

puts "T4.3 Sign KAP-KDM: OK"
puts "  #{File.join(output_dir, 'kdm.json')}"
puts "  signature_algorithm: #{kdm['signature']['algorithm']}"
