# T3 – Package Validation

Version: 0.9.0  
Status: Release Candidate  
Type: Normative Conformance Test Specification  
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH  
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1 Introduction

### 1.1 Purpose

This specification defines the reference validation process for Knowledge Asset Packages.

Package Validation verifies the structural integrity, cryptographic integrity and semantic consistency of a received Knowledge Asset Package before it is accepted for further processing.

The validation process produces deterministic and interoperable validation results for independent implementations.

### 1.2 Scope

This specification defines:

- the Package validation workflow,
- the execution order of validation steps,
- the validation of Package components,
- the validation of Package integrity,
- the Package Validation conformance tests.

This specification does not define:

- trust management,
- authorization,
- business-specific acceptance rules,
- package consumption,
- knowledge processing.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Conformance Test Suite.

It validates requirements defined by:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- S1 – Package Manifest Schema
- S2 – Packing List Schema
- S3 – Composition Schema

## 2 Package Validation

### 2.1 Purpose

Package Validation verifies that a received Knowledge Asset Package conforms to the KAPRI specification.

Successful validation confirms that the Package is structurally complete, cryptographically intact and internally consistent.

### 2.2 Validation Workflow

The reference validation workflow SHALL consist of the following steps.

1. Open Package.
2. Validate Package Manifest.
3. Validate Digital Signature.
4. Validate Certificate Chain.
5. Validate Packing List.
6. Validate Composition documents.
7. Validate Package Files.
8. Validate File Hashes.
9. Validate Cross References.
10. Generate Validation Report.

Each validation step SHALL successfully complete before the subsequent step is executed.

### 2.3 Validation Responsibilities

Technical Validation SHALL verify

- Package Structure
- Package Integrity
- Digital Signature
- Certificate Chain

Certificate Chain validation SHALL include verification that every certificate in the chain was valid at the published_at timestamp declared by the Package Manifest.

This includes verification of

- the presence of all mandatory Package components,
- schema conformance,
- Package completeness,
- file integrity,
- identifier consistency,
- document references,
- semantic consistency between Package components.

The validation process SHALL NOT modify the received Package.

## 3 Conformance Tests

The reference Package Validation SHALL provide the following executable conformance tests.

| Test | Purpose |
| --- | --- |
| T3.1 | Open Package |
| T3.2 | Validate Package Manifest |
| T3.3 | Validate Digital Signature |
| T3.4 | Validate Certificate Chain |
| T3.5 | Validate Packing List |
| T3.6 | Validate Composition |
| T3.7 | Validate Package Files |
| T3.8 | Validate File Hashes |
| T3.9 | Validate Cross References |
| T3.10 | Generate Validation Report |

## 4 Test Execution Order

The Package Validation tests SHALL be executed in the following order.
```
T3.1 Open Package
↓
T3.2 Validate Package Manifest
↓
T3.3 Validate Digital Signature
↓
T3.4 Validate Certificate Chain
↓
T3.5 Validate Packing List
↓
T3.6 Validate Composition
↓
T3.7 Validate Package Files
↓
T3.8 Validate File Hashes
↓
T3.9 Validate Cross References
↓
T3.10 Generate Validation Report
```

Each test depends on the successful completion of all preceding tests.

## 5 Expected Results

Technical Validation determines whether

- Package Structure is valid,
- Package Integrity is valid,
- Digital Signature is valid,
- Certificate Chain is valid.

This includes verification that

- all Package documents conform to their schemas,
- all referenced Package Files exist,
- all file hashes match,
- all document references are valid,
- the Package is internally consistent.

## 6 Conformance

An implementation claiming conformance with this specification SHALL:

- execute the validation workflow in the defined order,
- validate all mandatory Package components,
- preserve the received Package without modification,
- produce deterministic validation results,
- produce equivalent validation outcomes.


