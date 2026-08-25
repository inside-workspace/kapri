#!/usr/bin/env ruby
# T1.6 - Validate Reference Cryptographic Profile

require_relative "../../lib/kapri/cryptographic_profile"

DEFAULT_PKI_DIR = File.expand_path("../../certificates", __dir__)
pki_dir = ARGV[0] || DEFAULT_PKI_DIR

result = Kapri::CryptographicProfile.validate(pki_dir: pki_dir)

puts "T1.6 Validate Reference Cryptographic Profile: #{result.valid ? 'OK' : 'FEHLER'}"
result.checks.each { |name, valid| puts "  #{valid ? 'OK' : 'FEHLER'}  #{name}" }
result.errors.each { |error| puts "  - #{error}" }

exit(result.valid ? 0 : 1)
