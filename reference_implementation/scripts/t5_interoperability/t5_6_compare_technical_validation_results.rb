#!/usr/bin/env ruby
# T5.6 - Compare Technical Validation Results
#
# Gerüst - noch nicht implementiert. T5 setzt mindestens zwei unabhängig
# voneinander entwickelte Implementierungen voraus (specification/17:
# T5.md §1.1); bisher existiert nur die KAPRI-Referenzimplementierung
# selbst. Siehe lib/kapri/interoperability.rb.
#
#   ruby reference_implementation/scripts/t5_interoperability/t5_6_compare_technical_validation_results.rb [reference-report.json] [exchanged-report.json]

require_relative "../../lib/kapri/interoperability"

reference_report = ARGV[0]
exchanged_report = ARGV[1]

begin
  Kapri::Interoperability.compare_technical_validation_results(reference_report: reference_report, exchanged_report: exchanged_report)
rescue NotImplementedError => e
  puts "T5.6 Compare Technical Validation Results: NOT IMPLEMENTED"
  puts "  #{e.message}"
  exit 2
end
