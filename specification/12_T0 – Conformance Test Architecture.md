# T0 – Conformance Test Architecture

Version: 0.9.0
Status: Release Candidate
Type: Normative Conformance Test Architecture Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the architecture, organization and execution model of the KAPRI Conformance Test Suite.

The Conformance Test Suite provides executable tests for verifying conformance with the normative specifications of the KAPRI Specification Suite.

The Test Suite validates the KAPRI Reference Implementation as well as independent implementations.

### 1.2 Scope

This specification defines:

- the organization of the Conformance Test Suite,
- the execution order of the test groups,
- the responsibilities of each test group,
- the relationship between normative requirements and executable tests,
- the structure of individual tests,
- the use of Reference Test Artifacts.

This specification does not define:

- implementation-specific optimizations,
- production deployment,
- organizational trust policies,
- authorization policies,
- performance requirements.

### 1.3 Relationship to Other Specifications

The Conformance Test Suite provides executable tests for requirements defined by:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- S1 – Package Manifest Schema
- S2 – Packing List Schema
- S3 – Composition Schema
- S4 – KAP Key Delivery Message Schema

Every executable conformance test SHALL trace back to one or more normative requirements defined by the applicable specifications.

Cryptographic tests SHALL use the applicable Cryptographic Profile.

The Reference Cryptographic Profile used by the KAPRI Reference Implementation is defined by T1 – Public Key Infrastructure (PKI).

---

# 2. Architecture

## 2.1 Purpose

The Conformance Test Suite provides an executable framework for verifying structural, semantic and cryptographic conformance with the KAPRI Specification Suite.

It separates:

- Package Generation,
- Package Validation,
- Secure Delivery,
- Interoperability Testing.

Technical Validation SHALL remain distinct from Recipient Decisions as defined by S0 – Knowledge Asset Package Architecture Specification.

## 2.2 Test Hierarchy

```
T0  Conformance Test Architecture
│
├── T1  Public Key Infrastructure
├── T2  Package Generation
├── T3  Package Validation
├── T4  Secure Delivery
└── T5  Interoperability
```

The test groups have the following responsibilities:

| Test Group | Responsibility |
| --- | --- |
| T1 | Provide the Reference PKI and Reference Cryptographic Profile |
| T2 | Generate a conforming Knowledge Asset Package |
| T3 | Validate a Knowledge Asset Package |
| T4 | Perform and validate recipient-specific Secure Delivery |
| T5 | Verify interoperability between independent implementations |

## 2.3 Execution Order

The complete Conformance Test Suite SHALL be executed in the following logical order:

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/467e754e-cc00-4747-b41a-1e825ecbd464/pictures/1a28110e-f471-4b13-83d2-bfa3afe7dc05/content_img.png)

The defined execution order reflects the logical dependencies between the test groups.

Individual test groups MAY be executed independently where all required prerequisites and test artifacts are available.

---

# 3. Test Design Principles

Every executable test SHALL:

- verify one clearly defined requirement or validation criterion,
- produce deterministic validation results,
- be repeatable,
- be platform independent,
- use only publicly documented interfaces and formats.

Every test SHALL define:

- Purpose
- Input
- Output
- Expected Result
- Validation Criteria

Where applicable, a test SHALL identify the normative requirement or requirements being verified.

Cryptographic tests SHALL identify the applicable Cryptographic Profile.

---

# 4. Reference Test Artifacts

The Conformance Test Suite uses complementary test artifacts for different validation purposes.

## 4.1 Minimal Examples

Minimal, single-purpose examples SHALL be provided where isolated testing of a schema, data type or validation rule is required.

These examples are intended to make individual requirements independently testable without requiring a complete Knowledge Asset Package.

## 4.2 KAPRI Reference Package

The KAPRI Reference Package is a complete, realistic Knowledge Asset Package generated according to T2 – Package Generation.

It contains:

- one Package Manifest,
- one Packing List,
- one or more Compositions,
- all referenced Package Files.

The Reference Package MAY contain encrypted Package Files.

The Reference Package provides the shared test artifact for Package Validation and Interoperability Testing.

## 4.3 Secure Delivery Test Artifacts

Where the Reference Package contains encrypted Package Files, the Conformance Test Suite SHALL provide the additional artifacts required for T4 – Secure Delivery.

These include:

- File Keys corresponding to the Key Identifiers defined by the Packing List,
- a Recipient Certificate,
- the corresponding Recipient Private Key,
- one or more recipient-specific KAP-KDMs.

File Keys, Private Keys and KAP-KDMs SHALL NOT be part of the Knowledge Asset Package.

They are separate Conformance Test Artifacts.

## 4.4 PKI and Cryptographic Test Artifacts

Certificates and cryptographic keys required by the Reference Implementation SHALL be generated according to T1 – Public Key Infrastructure (PKI).

Private Keys SHALL NOT be part of the Knowledge Asset Package.

Standalone PKI certificates used by the test environment SHALL NOT be Package Files.

Certificates embedded as Certificate References according to SC1 – Common Data Types are part of the Package document in which they occur.

The certification chain embedded in the Package Manifest Signature is therefore part of the Package Manifest, while standalone certificate files used by the test environment are not Package Files.

---

# 5. Reference Implementation

The KAPRI Reference Implementation is implemented in Ruby.

The programming language used by the Reference Implementation is informative and does not constrain independent implementations.

The accompanying executable Conformance Tests are provided as independent Ruby scripts.

Each reference script SHALL:

- perform one clearly defined logical task,
- expose a documented command line interface,
- expose a reusable Ruby API,
- produce deterministic validation results.

Independent implementations MAY use any programming language or implementation technology.

Conformance is determined by observable behavior and validation results, not by implementation technology.

---

# 6. Test Organization

Each conformance test SHALL be documented as an individual Knowledge Asset.

A test consists of:

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/467e754e-cc00-4747-b41a-1e825ecbd464/pictures/73d2861a-0b54-4e3c-af97-95f1b42a909c/content_img.png)

The executable Ruby script is the Reference Implementation of the corresponding test and does not itself define the normative requirement.

The normative requirement originates from the applicable KAPRI specification.

---

# 7. Validation Model

The Conformance Test Suite distinguishes between Technical Validation, Recipient Decisions and Secure Delivery Validation.

The authoritative Validation Model is defined by S0 – Knowledge Asset Package Architecture Specification.

## 7.1 Technical Validation

Technical Validation determines whether a Knowledge Asset Package is technically valid according to the KAPRI Specification Suite.

Technical Validation SHALL evaluate all applicable Technical Validation categories defined by S0 – Knowledge Asset Package Architecture Specification.

These include, where applicable:

- Package Structure
- Package Integrity
- Digital Signature
- Certificate Chain

> Certificate validity SHALL be evaluated as part of Certificate Chain validation using the published_at timestamp of the Package Manifest, as defined by S0 – Knowledge Asset Package Architecture Specification.

Technical Validation SHALL produce deterministic results based on the Package, the applicable specifications and the applicable Cryptographic Profile.

Technical Validation SHALL NOT establish trust in the Producer or determine whether a Recipient accepts or processes the Package.

## 7.2 Recipient Decisions

Recipient Decisions determine whether a technically valid Knowledge Asset Package can or should be accepted and processed by a specific Recipient.

Recipient Decisions SHALL evaluate all applicable Recipient Decision categories defined by S0 – Knowledge Asset Package Architecture Specification.

These include, where applicable:

- Issuer Trust
- Product Support
- Version Compatibility

Recipient Decisions MAY depend on local configuration, trust policies and implementation capabilities.

Different conforming Recipients MAY therefore reach different Recipient Decisions for the same technically valid Package.

A Recipient Decision SHALL NOT change the result of Technical Validation.

## 7.3 Secure Delivery Validation

Secure Delivery Validation verifies recipient-specific cryptographic processing independently of Package Technical Validation.

Secure Delivery Validation is defined by T4 – Secure Delivery and includes, where applicable:

- KAP-KDM structure,
- KAP-KDM signature,
- KAP-KDM certification chain,
- Recipient Certificate binding,
- Encrypted File Key recovery,
- Package File decryption.

Successful Secure Delivery Validation does not by itself establish trust in the Producer or authorization of the Recipient.

---

# 8. Conformance

An implementation claiming conformance with the KAPRI Conformance Test Architecture SHALL:

- execute all applicable test groups in the defined logical order or satisfy their prerequisites independently,
- satisfy all mandatory validation criteria,
- produce equivalent results for every applicable Technical Validation category defined by S0 – Knowledge Asset Package Architecture Specification,
- correctly evaluate the applicable Recipient Decision categories defined by S0 – Knowledge Asset Package Architecture Specification,
- correctly perform all applicable Secure Delivery Validation defined by T4 – Secure Delivery,
- apply the applicable Cryptographic Profile to all cryptographic operations,
- preserve the semantics defined by the normative KAPRI specifications.
