#!/usr/bin/env ruby
# T5.4 - Validate Exchanged Package
#
# Gerüst - noch nicht implementiert. T5 setzt mindestens zwei unabhängig
# voneinander entwickelte Implementierungen voraus (specification/17:
# T5.md §1.1); bisher existiert nur die KAPRI-Referenzimplementierung
# selbst. Siehe lib/kapri/interoperability.rb.
#
#   ruby reference_implementation/scripts/t5_interoperability/t5_4_validate_exchanged_package.rb [package-verzeichnis]

require_relative "../../lib/kapri/interoperability"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

package_dir = ARGV[0] || DEFAULT_OUTPUT_DIR

begin
  Kapri::Interoperability.validate_exchanged_package(package_dir: package_dir)
rescue NotImplementedError => e
  puts "T5.4 Validate Exchanged Package: NOT IMPLEMENTED"
  puts "  #{e.message}"
  exit 2
end
