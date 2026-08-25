#!/usr/bin/env ruby
# Validiert ein herstellerunabhängiges Package im Conformance-Testbereich.
# Das Package selbst wird nicht verändert. Validation Report, interner Zustand
# und gegebenenfalls entschlüsselte Kontrollausgaben liegen daneben.
#
#   ruby conformance_test/scripts/validate_package.rb <package-name> [pki-verzeichnis]

require "json"
require_relative "../../reference_implementation/lib/kapri/package_validation"
require_relative "../../reference_implementation/lib/kapri/secure_delivery"
require_relative "../../reference_implementation/lib/kapri/conformance_paths"

DEFAULT_PKI_DIR = File.expand_path("../../reference_implementation/certificates", __dir__)

package_name = ARGV[0] or abort "Usage: #{$PROGRAM_NAME} <package-name> [pki-verzeichnis]"
pki_dir = ARGV[1] || DEFAULT_PKI_DIR
work_dir = Kapri::ConformancePaths.conformance_work_dir(package_name)
package_dir = Kapri::ConformancePaths.package_dir(package_name)
raise "#{package_dir} fehlt - zuerst ein Package aus dem Staging übergeben" unless File.directory?(package_dir)

report = Kapri::PackageValidation.generate_report(output_dir: work_dir)
puts "T3 Package Validation:"
report.categories.each do |category|
  puts "  #{category.name.ljust(18)} #{category.valid ? 'valid' : 'invalid'}"
  category.errors.each { |error| puts "    - #{error}" }
end
puts "  #{'Overall Result'.ljust(18)} #{report.valid ? 'VALID' : 'INVALID'}"

kdm_valid = true
kdm_path = Kapri::ConformancePaths.kdm_path(package_name)
if File.exist?(kdm_path)
  kdm_result = Kapri::SecureDelivery.validate_kdm(output_dir: work_dir)
  kdm_valid = kdm_result.valid
  puts "KDM Validation: #{kdm_result.valid ? 'valid' : 'invalid'}"
  kdm_result.errors.each { |e| puts "  - #{e}" }

  if report.valid && kdm_result.valid
    recovered = Kapri::SecureDelivery.recover_file_keys(output_dir: work_dir, pki_dir: pki_dir)
    decrypted = Kapri::SecureDelivery.decrypt_package_files(output_dir: work_dir)
    puts "File Keys wiederhergestellt: #{recovered.size}"
    puts "Dateien entschlüsselt:       #{decrypted.size}"
  end
else
  packing_list = JSON.parse(File.read(File.join(package_dir, "packing-list.json")))
  encrypted_files = packing_list.fetch("files", []).count { |entry| entry.is_a?(Hash) && entry["key_id"] }
  if encrypted_files.positive?
    kdm_valid = false
    puts "KDM Validation: invalid (#{encrypted_files} verschlüsselte Package Files, aber kdm.json fehlt)"
  else
    puts "KDM Validation: nicht anwendbar (keine verschlüsselten Package Files)"
  end
end

puts "Conformance-Testbereich: #{work_dir}"
puts "Package Container blieb unverändert: #{package_dir}"

exit(report.valid && kdm_valid ? 0 : 1)
