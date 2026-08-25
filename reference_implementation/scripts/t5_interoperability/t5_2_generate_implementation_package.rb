#!/usr/bin/env ruby
# T5.2 - Generate Implementation Package
#
# Gerüst - noch nicht implementiert. T5 setzt mindestens zwei unabhängig
# voneinander entwickelte Implementierungen voraus (specification/17:
# T5.md §1.1); bisher existiert nur die KAPRI-Referenzimplementierung
# selbst. Siehe lib/kapri/interoperability.rb.
#
#   ruby reference_implementation/scripts/t5_interoperability/t5_2_generate_implementation_package.rb [package-verzeichnis] [pki-verzeichnis]

require_relative "../../lib/kapri/interoperability"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)
DEFAULT_PKI_DIR    = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
pki_dir    = ARGV[1] || DEFAULT_PKI_DIR

begin
  Kapri::Interoperability.generate_implementation_package(output_dir: output_dir, pki_dir: pki_dir)
rescue NotImplementedError => e
  puts "T5.2 Generate Implementation Package: NOT IMPLEMENTED"
  puts "  #{e.message}"
  exit 2
end
