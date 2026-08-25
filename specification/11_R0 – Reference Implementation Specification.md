# R0 – Reference Implementation Specification

Version: 0.9.0
Status: Release Candidate
Type: Informative Implementation Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification describes the Reference Implementation accompanying the KAPRI Specification Suite.

The Reference Implementation demonstrates that the normative specifications can be implemented consistently and interoperably. This specification describes its architecture, scope, objectives, and design principles.

Unlike the normative specifications, this document does not define conformance requirements.

### 1.2 Scope

This specification defines

- the objectives of the Reference Implementation,
- the functional modules provided,
- the relationship between the implementation and the normative specifications,
- implementation principles,
- the relationship to the Conformance Tests.

This specification does not define

- normative package structures,
- schema definitions,
- validation rules,
- implementation technologies,
- programming interfaces.

These subjects are defined by the corresponding normative specifications.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Specification Suite.

The Reference Implementation provides an executable implementation of the normative specifications defined by

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- S1 – Package Manifest Schema
- S2 – Packing List Schema
- S3 – Composition Schema
- S4 – KAP Key Delivery Message Schema

Conformance of the Reference Implementation is verified by the Conformance Tests defined in T0.

## 2. Overview

The Reference Implementation provides an open implementation of the KAPRI Specification Suite.

Its purpose is to

- demonstrate the practical applicability of the specifications,
- provide executable examples,
- support interoperability between independent implementations,
- serve as the foundation for the Conformance Tests,
- provide reusable implementation components for developers.

This specification is informative.

Independent implementations are free to use different programming languages, libraries, or software architectures while remaining fully conformant with the normative specifications.

## 3. Functional Modules

The Reference Implementation consists of a set of independent implementation modules.

Each module addresses one architectural responsibility.

### 3.1 Public Key Infrastructure

Implements the creation and validation of the certificate hierarchy used by the Reference Implementation.

Typical functionality includes

- Root CA generation,
- Intermediate CA generation,
- Producer certificates,
- Recipient certificates,
- certificate chain validation.

The Cryptographic Profile (hash and signature algorithms) used by the Reference Implementation is defined by T1 – Public Key Infrastructure SS2.4.

### 3.2 Package Generation

Implements the creation of complete Knowledge Asset Packages.

Typical functionality includes

- Package Manifest generation,
- Packing List generation,
- Composition generation,
- package assembly.

### 3.3 Secure Delivery

Implements

- file encryption,
- File Key generation,
- KAP-KDM generation,
- digital signature creation.

### 3.4 Package Validation

Implements technical validation of received Packages.

Typical functionality includes

- schema validation,
- integrity verification,
- signature validation,
- certificate chain validation,
- Package consistency validation.

### 3.5 Utilities

Provides reusable implementation components shared by multiple modules.

Typical utilities include

- canonical JSON generation,
- hash calculation,
- identifier generation,
- file processing,
- serialization support.

## 4. Design Principles

The Reference Implementation follows the principles below.

### 4.1 Informative Implementation

The Reference Implementation demonstrates one valid implementation of the KAPRI specifications.

It does not define additional normative requirements.

### 4.2 Open Implementation

The complete source code of the Reference Implementation SHALL be publicly available.

### 4.3 Readability

Implementation clarity takes precedence over implementation optimization.

The Reference Implementation is intended to support understanding of the specifications.

### 4.4 Deterministic Behaviour

Identical input SHALL always produce identical output unless cryptographic randomness is explicitly required.

### 4.5 Modular Structure

Implementation modules SHALL remain independent whenever practical.

Individual modules MAY be reused independently by other implementations.

## 5. Relationship to the Conformance Tests

The Reference Implementation provides one executable implementation of the KAPRI specifications.

Conformance is not established by the Reference Implementation itself.

Instead, conformance is verified by the Conformance Tests defined by T0.

This separation enables independent software implementations to claim conformance without using the Reference Implementation.

## 6. Extensibility

The Reference Implementation MAY evolve independently of the normative specifications.

Future versions MAY introduce

- additional implementation modules,
- additional programming languages,
- additional utilities,
- additional validation tools,

provided that they remain consistent with the normative specifications of the KAPRI Specification Suite.

## 7. Conformance

### 7.1 General

The Reference Implementation implements the normative specifications of the KAPRI Specification Suite.

Successful execution of the Reference Implementation does not by itself establish conformance.

Conformance is determined exclusively by the Conformance Tests defined by T0.

### 7.2 Interoperability

The Reference Implementation demonstrates one interoperable implementation of the KAPRI specifications.

Other implementations MAY use different software architectures or implementation technologies while preserving the externally observable behaviour and interoperability defined by the normative specifications.

 
