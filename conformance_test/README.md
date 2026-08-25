# Conformance Test

This directory contains an implementation-independent test workspace. It has
no dependency on a source system, export format or staging process.

## Included example

```text
conformance_test/example/
└── package/
    ├── manifest.json
    ├── packing-list.json
    ├── compositions/
    └── files/example.md
```

The example is deliberately small: one unencrypted Package File, one
Composition, one Packing List and one signed Manifest. Its embedded certificate
chain contains public certificates only.

Validate it from the repository root:

```bash
bundle exec ruby conformance_test/scripts/validate_package.rb example
```

The validator writes `conformance_test/example/validation-report.json` beside
the immutable Package Container. The expected overall result is `VALID`.

## Encrypted Packages

For a Package containing encrypted Package Files, place the producer's local
File-Key state beside `package/`, generate the recipient-specific KAP-KDM and
then validate the complete delivery workspace:

```bash
bundle exec ruby conformance_test/scripts/generate_kdm.rb <package-name> <pki-directory>
bundle exec ruby conformance_test/scripts/validate_package.rb <package-name> <pki-directory>
```

The KAP-KDM, validation report, internal state and decrypted control output are
not part of the Knowledge Asset Package.
