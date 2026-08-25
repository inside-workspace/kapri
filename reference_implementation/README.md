# KAPRI Reference Implementation

Executable Ruby reference implementation for the KAPRI T1–T5 conformance-test
specifications. Normative JSON-Schema validation uses `json_schemer`.

```bash
bundle install
```

## Structure

| Path | Contents |
|---|---|
| `lib/kapri/` | Reusable PKI, Package Generation, Package Validation, Secure Delivery and interoperability components |
| `scripts/t1_public_key_infrastructure/` | T1.1–T1.6: generate and validate the reference PKI and cryptographic profile |
| `scripts/t2_package_generation/` | T2.1–T2.7: generate and sign a Package |
| `scripts/t3_package_validation/` | T3.1–T3.10: validate a Package |
| `scripts/t4_secure_delivery/` | T4.1–T4.6: generate and validate a KAP-KDM, recover keys and decrypt files |
| `scripts/t5_interoperability/` | T5.1–T5.7 interoperability-test scaffold |

`certificates/`, `output/` and `keystore/` are generated local workspaces and
are intentionally not published. The T1 scripts generate test-only private
keys. They must never be used as production keys.

## Complete T1–T4 run

Run these commands from the repository root:

```bash
PKI=reference_implementation/certificates
OUT=reference_implementation/output
mkdir -p "$PKI" "$OUT"

# T1 — Public Key Infrastructure
ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_1_generate_root_certification_authority.rb "$PKI"
ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_2_generate_intermediate_certification_authority.rb "$PKI"
ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_3_generate_producer_certificate.rb "$PKI"
ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_4_generate_recipient_certificate.rb "$PKI"
ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_5_validate_certification_chain.rb "$PKI"
ruby reference_implementation/scripts/t1_public_key_infrastructure/t1_6_validate_reference_cryptographic_profile.rb "$PKI"

# T2 — Package Generation
ruby reference_implementation/scripts/t2_package_generation/t2_1_generate_package_files.rb "$OUT"
ruby reference_implementation/scripts/t2_package_generation/t2_2_encrypt_package_files.rb "$OUT"
ruby reference_implementation/scripts/t2_package_generation/t2_3_generate_packing_list.rb "$OUT"
ruby reference_implementation/scripts/t2_package_generation/t2_4_generate_composition.rb "$OUT"
ruby reference_implementation/scripts/t2_package_generation/t2_5_generate_package_manifest.rb "$OUT"
ruby reference_implementation/scripts/t2_package_generation/t2_6_canonicalize_package_manifest.rb "$OUT"
ruby reference_implementation/scripts/t2_package_generation/t2_7_digitally_sign_package_manifest.rb "$OUT" "$PKI"

# T3 — Package Validation
ruby reference_implementation/scripts/t3_package_validation/t3_10_generate_validation_report.rb "$OUT"

# T4 — Secure Delivery
ruby reference_implementation/scripts/t4_secure_delivery/t4_1_encrypt_file_keys.rb "$OUT" "$PKI"
ruby reference_implementation/scripts/t4_secure_delivery/t4_2_generate_key_delivery_message.rb "$OUT" "$PKI"
ruby reference_implementation/scripts/t4_secure_delivery/t4_3_sign_key_delivery_message.rb "$OUT" "$PKI"
ruby reference_implementation/scripts/t4_secure_delivery/t4_4_validate_key_delivery_message.rb "$OUT"
ruby reference_implementation/scripts/t4_secure_delivery/t4_5_recover_file_keys.rb "$OUT" "$PKI"
ruby reference_implementation/scripts/t4_secure_delivery/t4_6_decrypt_package_files.rb "$OUT"
```

The Package Container is written to `output/package/`. KAP-KDM, internal state,
validation report and decrypted control output remain outside that container.

## T5 Interoperability

T5 verifies exchange between independently developed Producer and Consumer
implementations. Only one implementation exists in this repository, so the T5
methods deliberately raise `NotImplementedError` until a second implementation
is supplied for an actual interoperability test.
