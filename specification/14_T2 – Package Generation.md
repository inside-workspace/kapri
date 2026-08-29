# T2 – Package Generation

Version: 0.9.0  
Status: Release Candidate  
Type: Normative Conformance Test Specification  
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH  
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1 Introduction

### 1.1 Purpose

This specification defines the reference process for generating a Knowledge Asset Package.

The Package Generation process transforms a published version of a Knowledge Asset and its associated resources into a complete, signed Knowledge Asset Package conforming to the KAPRI Specification Suite.

The generated Package serves as the Reference Package used for interoperability and conformance testing.

### 1.2 Scope

This specification defines:

- the Package Generation workflow,
- the execution order of generation steps,
- the generated Package components,
- optional encryption of Package Files,
- the Package Generation conformance tests.

This specification does not define:

- knowledge authoring,
- content management,
- editing environments,
- production workflows,
- recipient-specific key delivery.

Recipient-specific key delivery is defined separately by T4 – Secure Delivery.

### 1.3 Relationship to Other Specifications

This specification validates requirements defined by:

- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- S1 – Package Manifest Schema
- S2 – Packing List Schema
- S3 – Composition Schema

Cryptographic algorithms and parameters SHALL conform to the applicable Cryptographic Profile.

The Reference Cryptographic Profile used by the KAPRI Reference Implementation is defined by T1 – Public Key Infrastructure (PKI).

Recipient-specific delivery of File Keys is defined by T4 – Secure Delivery.

The generated Package SHALL conform to all applicable referenced specifications.

## 2 Package Generation

### 2.1 Purpose

Package Generation produces a complete Knowledge Asset Package from a published version of a Knowledge Asset and its associated resources.

The resulting Package SHALL be:

- structurally complete,
- internally consistent,
- integrity-protected,
- digitally signed,
- suitable for independent validation by conforming Recipients.

Package Files MAY be encrypted before inclusion in the Package.

### 2.2 Generation Workflow

The reference Package Generation workflow SHALL consist of the following steps:
```
Knowledge Asset Version Selected for Publication
↓
Generate Package Files
↓
Encrypt Package Files (if required)
↓
Generate Packing List
↓
Generate Composition
↓
Generate Package Manifest
↓
Canonicalize Package Manifest
↓
Digitally Sign Package Manifest
↓
Knowledge Asset Package
```
If Package Files are encrypted, recipient-specific File Key delivery SHALL be performed separately according to T4 – Secure Delivery.

### 2.3 Generated Components

The generated Knowledge Asset Package SHALL contain:

- exactly one Package Manifest,
- exactly one Packing List,
- one or more Compositions,
- all Package Files referenced by the Packing List.

A KAP-KDM SHALL NOT be part of the Knowledge Asset Package.

Recipient-specific KAP-KDMs MAY be generated separately according to T4 – Secure Delivery.

### 2.4 Package File Generation

Package Files represent the serialized content and associated resources of the published Knowledge Asset version.

Each Package File included in the Package SHALL be represented by an entry in the Packing List.

Package File generation SHALL be completed before the Packing List is generated.

### 2.5 Package File Encryption

Package Files MAY be encrypted before inclusion in the Package.

If a Package File is encrypted:

- a unique symmetric File Key SHALL be generated for that File,
- the File SHALL be encrypted using the applicable Cryptographic Profile,
- the encrypted representation SHALL become the Package File,
- the corresponding Key Identifier SHALL be recorded in the Packing List.

The File Key itself SHALL NOT be contained in the Knowledge Asset Package.

File Keys required by a Recipient are delivered separately through a KAP-KDM according to T4 – Secure Delivery.

### 2.6 Packing List Generation

The Packing List SHALL describe the physical Package Files as they are contained in the final Package.

For every Package File, the Packing List SHALL contain the properties required by S2 – Packing List Schema.

Hashes and File Sizes SHALL be calculated from the final serialized Package Files.

For encrypted Package Files, hashes and File Sizes SHALL therefore be calculated from the encrypted representation.

### 2.7 Composition Generation

At least one Composition SHALL be generated.

Compositions SHALL describe the semantic structure of the published Knowledge Asset version according to S3 – Composition Schema.

Every referenced Package File SHALL be identifiable through the Package structures defined by the KAPRI Specification Suite.

### 2.8 Package Manifest Generation

Exactly one Package Manifest SHALL be generated.

The Package Manifest SHALL:

- identify the Package,
- identify the published Knowledge Asset version,
- identify the Responsible Organization,
- reference the Packing List,
- reference all Compositions,
- contain all mandatory properties defined by S1 – Package Manifest Schema.

Document References SHALL contain the cryptographic hashes of the referenced Package documents.

### 2.9 Manifest Canonicalization

Before signature generation, the Package Manifest SHALL be transformed into its canonical JSON representation according to RFC 8785 – JSON Canonicalization Scheme (JCS).

The signature property SHALL be excluded from the canonical representation used for signature generation.

The resulting canonical representation SHALL be used as the input to the digital signature operation.

### 2.10 Manifest Signature

The canonical representation of the Package Manifest SHALL be digitally signed.

The signature scheme and all required cryptographic parameters SHALL conform to the applicable Cryptographic Profile.

The signing certificate and complete certification chain SHALL be represented according to the Signature and Certificate Reference data types defined by SC1 – Common Data Types.

The resulting Signature SHALL be stored in the signature property of the Package Manifest.

## 3 Conformance Tests

The Reference Package Generation SHALL provide the following executable conformance tests.

| Test | Purpose |
| --- | --- |
| T2.1 | Generate Package Files |
| T2.2 | Encrypt Package Files, if required |
| T2.3 | Generate Packing List |
| T2.4 | Generate Composition |
| T2.5 | Generate Package Manifest |
| T2.6 | Canonicalize Package Manifest |
| T2.7 | Digitally Sign Package Manifest |

### T2.1 Generate Package Files

The test SHALL generate all Package Files required by the Reference Package.

Expected result: All required Package Files exist and are suitable for further Package processing.

### T2.2 Encrypt Package Files

If encrypted Package Files are used by the Reference Package, the test SHALL:

- generate one unique symmetric File Key for each encrypted File,
- generate a Key Identifier for each File Key,
- encrypt each File according to the Reference Cryptographic Profile.

Expected result: Each protected Package File exists in encrypted form and has an associated Key Identifier and File Key.

The File Keys SHALL be retained outside the Package for subsequent Secure Delivery testing according to T4.

If the Reference Package contains no encrypted Package Files, this test is not applicable.

### T2.3 Generate Packing List

The test SHALL generate the Packing List from the final Package Files.

Expected result: The Packing List contains a valid entry for every Package File, including its File Identifier, File Path, Hash, Hash Algorithm, File Size, Media Type and, where applicable, Key Identifier.

### T2.4 Generate Composition

The test SHALL generate at least one Composition describing the semantic structure of the Reference Package.

Expected result: The generated Composition conforms to S3 – Composition Schema and references the applicable Package content consistently.

### T2.5 Generate Package Manifest

The test SHALL generate the Package Manifest and its Document References.

Expected result: The Manifest conforms to S1 – Package Manifest Schema and references the generated Packing List and all generated Compositions.

### T2.6 Canonicalize Package Manifest

The test SHALL canonicalize the Package Manifest according to RFC 8785 with the signature property excluded.

Expected result: A deterministic canonical representation of the Package Manifest is produced.

### T2.7 Digitally Sign Package Manifest

The test SHALL digitally sign the canonical Package Manifest using the Producer Private Key and the Reference Cryptographic Profile defined by T1 – Public Key Infrastructure (PKI).

The complete certification chain SHALL be included in the Signature according to SC1 – Common Data Types.

Expected result: The Package Manifest contains a valid Signature that can be independently verified using the included certification chain.

## 4 Test Execution Order

The Package Generation tests SHALL be executed in the following order:
```
T2.1 Generate Package Files
↓
T2.2 Encrypt Package Files (if required)
↓
T2.3 Generate Packing List
↓
T2.4 Generate Composition
↓
T2.5 Generate Package Manifest
↓
T2.6 Canonicalize Package Manifest
↓
T2.7 Digitally Sign Package Manifest
```
Each applicable test depends on the successful completion of all preceding applicable tests.

## 5 Expected Results

The generated Knowledge Asset Package SHALL:

- contain all mandatory Package components,
- contain all Package Files referenced by the Packing List,
- satisfy all structural requirements,
- contain valid references between Package components,
- satisfy all applicable integrity requirements,
- contain a valid digital signature,
- conform to the applicable Cryptographic Profile,
- be suitable for independent validation by conforming Recipients.

If Package Files are encrypted:

- each encrypted File SHALL have a unique File Key,
- each File Key SHALL have a Key Identifier,
- the corresponding Key Identifier SHALL be recorded in the Packing List,
- File Keys SHALL NOT be contained in the Package.

## 6 Conformance

An implementation claiming conformance with this specification SHALL:

- execute the applicable Package Generation tests in the defined order,
- generate Package components conforming to S1–S3,
- preserve all identifiers and references,
- apply the applicable Cryptographic Profile for Package File encryption and digital signature generation,
- produce a Knowledge Asset Package that successfully passes all applicable Technical Validation defined by S0 – Knowledge Asset Package Architecture Specification.
