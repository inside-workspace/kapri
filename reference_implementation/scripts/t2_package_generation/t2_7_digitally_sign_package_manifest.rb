#!/usr/bin/env ruby
# T2.7 - Digitally Sign Package Manifest
#
# Signiert die kanonische Repräsentation (T2.6) des Package Manifest mit dem
# Producer-Zertifikat aus der T1-Referenz-PKI und schreibt den vollständigen,
# schema-validen Package Manifest. Voraussetzung: T2.5 sowie T1.1-T1.4 wurden
# zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_7_digitally_sign_package_manifest.rb [ziel-verzeichnis] [pki-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)
DEFAULT_PKI_DIR    = File.expand_path("../../certificates", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
pki_dir    = ARGV[1] || DEFAULT_PKI_DIR

result = Kapri::PackageGeneration.sign_manifest(output_dir: output_dir, pki_dir: pki_dir)

puts "T2.7 Digitally Sign Package Manifest: OK"
puts "  #{result.path}"
puts "  signature_algorithm: #{result.manifest['signature']['algorithm']}"
