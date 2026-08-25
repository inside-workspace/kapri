#!/usr/bin/env ruby
# T4.2 - Generate KAP-KDM
#
# Baut die (noch unsignierte) KAP-KDM aus den verpackten File Keys (T4.1),
# dem Package Manifest und dem Recipient-Zertifikat aus der T1-Referenz-PKI.
# Voraussetzung: T4.1, T2.7, T1.1-T1.4.
#
#   ruby reference_implementation/scripts/t4_secure_delivery/t4_2_generate_key_delivery_message.rb [package-verzeichnis] [pki-verzeichnis] [recipient-organization-id] [recipient-organization-name]

require_relative "../../lib/kapri/secure_delivery"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)
DEFAULT_PKI_DIR    = File.expand_path("../../certificates", __dir__)
DEFAULT_RECIPIENT_ORGANIZATION_ID   = "urn:kap:organization:kapri-reference-recipient"
DEFAULT_RECIPIENT_ORGANIZATION_NAME = "KAPRI Reference Recipient"

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
pki_dir    = ARGV[1] || DEFAULT_PKI_DIR
recipient_organization_id   = ARGV[2] || DEFAULT_RECIPIENT_ORGANIZATION_ID
recipient_organization_name = ARGV[3] || DEFAULT_RECIPIENT_ORGANIZATION_NAME

kdm = Kapri::SecureDelivery.generate_kdm(
  output_dir: output_dir,
  pki_dir: pki_dir,
  recipient_organization_id: recipient_organization_id,
  recipient_organization_name: recipient_organization_name
)

puts "T4.2 Generate KAP-KDM: OK"
puts "  kdm_id: #{kdm['kdm_id']} (unsigniert - siehe T4.3)"
