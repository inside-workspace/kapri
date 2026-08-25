#!/usr/bin/env ruby
# T2.6 - Canonicalize Package Manifest
#
# Transformiert den unsignierten Package Manifest (T2.5) gemäß RFC 8785
# (JSON Canonicalization Scheme) in seine kanonische Repräsentation, wie von
# S1 §3.2.14 für Signaturbildung und -prüfung gefordert.
# Voraussetzung: T2.5 wurde zuvor ausgeführt.
#
#   ruby reference_implementation/scripts/t2_package_generation/t2_6_canonicalize_package_manifest.rb [ziel-verzeichnis]

require_relative "../../lib/kapri/package_generation"

DEFAULT_OUTPUT_DIR = File.expand_path("../../output", __dir__)

output_dir = ARGV[0] || DEFAULT_OUTPUT_DIR
result = Kapri::PackageGeneration.canonicalize_manifest(output_dir: output_dir)

puts "T2.6 Canonicalize Package Manifest: OK"
puts "  #{result.path} (#{result.canonical_bytes.bytesize} bytes)"
