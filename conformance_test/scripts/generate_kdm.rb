#!/usr/bin/env ruby
# Erzeugt die optionale KAP-KDM für ein bereits vorhandenes, valides Package.
# Kennt weder den Inside-Export noch build.json; Eingabe ist ausschließlich der
# interoperable Package Container plus der beim Verschlüsseln erzeugte interne
# File-Key-Zustand.
#
#   ruby conformance_test/scripts/generate_kdm.rb <package-name> [pki-verzeichnis]

require "json"
require_relative "../../reference_implementation/lib/kapri/package_generation"
require_relative "../../reference_implementation/lib/kapri/package_validation"
require_relative "../../reference_implementation/lib/kapri/secure_delivery"
require_relative "../../reference_implementation/lib/kapri/conformance_paths"
require_relative "../../reference_implementation/lib/kapri/workspace"

DEFAULT_PKI_DIR = File.expand_path("../../reference_implementation/certificates", __dir__)

package_name = ARGV[0] or abort "Usage: #{$PROGRAM_NAME} <package-name> [pki-verzeichnis]"
pki_dir = ARGV[1] || DEFAULT_PKI_DIR
work_dir = Kapri::ConformancePaths.conformance_work_dir(package_name)
package_dir = Kapri::ConformancePaths.package_dir(package_name)
raise "#{package_dir} fehlt - zuerst ein Package aus dem Staging übergeben" unless File.directory?(package_dir)

report = Kapri::PackageValidation.generate_report(output_dir: work_dir)
raise "Package ist INVALID - keine KDM erzeugt; siehe #{Kapri::Workspace.report_path(work_dir)}" unless report.valid

packing_list = JSON.parse(File.read(File.join(package_dir, "packing-list.json")))
key_ids = packing_list.fetch("files").filter_map { |entry| entry["key_id"] }

if key_ids.empty?
  puts "Keine KDM erforderlich: Das Package enthält keine verschlüsselten Package Files."
  exit 0
end

Kapri::SecureDelivery.encrypt_file_keys(output_dir: work_dir, pki_dir: pki_dir)
Kapri::SecureDelivery.generate_kdm(
  output_dir: work_dir,
  pki_dir: pki_dir,
  recipient_organization_id: Kapri::PackageGeneration::RECIPIENT_ORGANIZATION_ID,
  recipient_organization_name: Kapri::PackageGeneration::RECIPIENT_ORGANIZATION_NAME,
  schema_version: Kapri::PackageGeneration::SCHEMA_VERSION
)
Kapri::SecureDelivery.sign_kdm(output_dir: work_dir, pki_dir: pki_dir)

result = Kapri::SecureDelivery.validate_kdm(output_dir: work_dir)
unless result.valid
  result.errors.each { |error| warn "- #{error}" }
  raise "Erzeugte KDM ist INVALID"
end

puts "KDM erzeugt und validiert: #{Kapri::ConformancePaths.kdm_path(package_name)}"
