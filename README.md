# KAPRI — Knowledge Asset Package Reference Implementation

KAPRI is an open specification for publishing, exchanging and validating
defined states of knowledge as interoperable Knowledge Asset Packages.

This repository contains the KAPRI Specification Suite, normative JSON
Schemas, an executable Ruby reference implementation and a minimal signed
Package for conformance testing.

## Status

Version 0.9.0 — Release Candidate

## Repository structure

| Path | Contents |
|---|---|
| `specification/` | KAPRI architecture, schemas, reference implementation and conformance-test specifications |
| `schemas/` | Normative JSON Schemas for Manifest, Packing List, Composition and KAP-KDM documents |
| `reference_implementation/` | Reusable Ruby implementation and executable T1–T5 test scripts |
| `conformance_test/` | Minimal signed example Package and implementation-independent validation helpers |

Generated certificates, private keys, implementation state and test output are
intentionally not included in the repository.

## Quick start

Install the Ruby dependency:

```bash
bundle install
```

Validate the included minimal Package:

```bash
bundle exec ruby conformance_test/scripts/validate_package.rb example
```

The expected overall result is `VALID`. The generated validation report is a
local test artifact and is ignored by Git.

For the complete T1–T4 workflow, including generation of a local reference PKI
and Secure Delivery, see
[`reference_implementation/README.md`](reference_implementation/README.md).
T5 requires a second independently developed implementation and is therefore
provided as an explicit interoperability-test scaffold.

## License

KAPRI uses two complementary licenses:

- Specification and documentation: Creative Commons Attribution 4.0 International (CC BY 4.0)
- Schemas, reference implementation and conformance-test material: Apache License 2.0

See [`LICENSE`](LICENSE) for the component mapping and the accompanying full
license texts.
