#!/usr/bin/env ruby
# T5.7 - Determine Interoperability
#
# Gerüst - noch nicht implementiert. T5 setzt mindestens zwei unabhängig
# voneinander entwickelte Implementierungen voraus (specification/17:
# T5.md §1.1); bisher existiert nur die KAPRI-Referenzimplementierung
# selbst. Siehe lib/kapri/interoperability.rb.
#
#   ruby reference_implementation/scripts/t5_interoperability/t5_7_determine_interoperability.rb [comparison-result.json]

require_relative "../../lib/kapri/interoperability"

comparison_result = ARGV[0]

begin
  Kapri::Interoperability.determine_interoperability(comparison_result: comparison_result)
rescue NotImplementedError => e
  puts "T5.7 Determine Interoperability: NOT IMPLEMENTED"
  puts "  #{e.message}"
  exit 2
end
