# K0 – Knowledge Asset Package Architecture Guide

Version: 0.9.0

Status: Informative

Type: Architecture Guide
Author: Sabine Wax
Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

 

## 1. Introduction

### 1.1 Purpose

This document provides an architectural overview of the Knowledge Asset Package (KAP) Specification Suite. It introduces the motivation, concepts and architectural structure of the individual specifications.

Unlike the normative specifications of the Knowledge Asset Package Specification Suite, this document is informative and does not define conformance requirements.

### 1.2 Audience

This document is intended for

- Enterprise Architects
- Software Architects
- Knowledge Management Professionals
- Standards Developers
- Software Implementers
- Decision Makers

It provides the conceptual foundation required to understand the normative specifications.

### 1.3 Scope

This document introduces

- the motivation behind Knowledge Assets,
- the architecture of the Knowledge Asset Package Specification Suite,
- the relationship between the specifications,
- the fundamental architectural principles,
- the overall processing model.

It does not define normative requirements.

## 2. Why Knowledge Assets?

Organizations increasingly publish and exchange knowledge across organizational boundaries.

Traditional documents provide information but do not explicitly identify the responsible organization, version, scope, or integrity of the represented knowledge.

Knowledge Assets address this limitation by treating organizational knowledge as a managed and publishable asset.

A Knowledge Asset represents the accountable and versioned state of knowledge within a defined scope.

A Knowledge Asset Package provides an interoperable representation that enables independent organizations to exchange, validate, and use Knowledge Assets consistently.

## 3. The Specification Suite

The Knowledge Asset Package Specification Suite consists of a family of complementary specifications organized into architectural layers. Each layer addresses a distinct architectural concern while building upon the abstractions defined by the preceding layers.

| Identifier | Specification |
| --- | --- |
| **K0** | Knowledge Asset Package Architecture Guide |
| **A0** | General Asset Model |
| **A1** | Knowledge Asset Reference Model |
| **S0** | Knowledge Asset Package Architecture Specification |
| **SC0** | Common Serialization Rules |
| **SC1** | Common Data Types |
| **S1** | Package Manifest Schema |
| **S2** | Packing List Schema |
| **S3** | Composition Schema |
| **S4** | KAP Key Delivery Message Schema |
| **R0** | Reference Implementation Specification |
| **T0** | Conformance Test Architecture |
| **T1** | Public Key Infrastructure (PKI) |
| **T2** | Package Generation |
| **T3** | Package Validation |
| **T4** | Secure Delivery |
| **T5** | Interoperability |

Together, these specifications define the conceptual models, package architecture, common rules, package schemas, reference implementation, and conformance tests that constitute the Knowledge Asset Package Specification Suite.

Each specification is independently versioned and evolves independently. Changes to one specification are intended not to require changes to unrelated specifications.

## 4. Architectural Layers

The Knowledge Asset Package Specification Suite separates architectural concerns into distinct architectural layers.

```
Knowledge Asset Package Specification Suite
│
├── Reference Models
│      ├── A0 General Asset Model
│      └── A1 Knowledge Asset Reference Model
│
├── Package Architecture
│      └── S0
│
├── Common Specifications
│      ├── SC0 Common Serialization Rules
│      └── SC1 Common Data Types
│
├── Package Schemas
│      ├── S1 Package Manifest
│      ├── S2 Packing List
│      ├── S3 Composition
│      └── S4 KAP-KDM
│
├── Reference Implementation
│      └── R0
│
└── Conformance Tests
       ├── T0 Conformance Test Architecture
       ├── T1 Public Key Infrastructure
       ├── T2 Package Generation
       ├── T3 Package Validation
       ├── T4 Secure Delivery
       └── T5 Interoperability
```

Each layer addresses a specific architectural concern while building upon the abstractions defined by the preceding layers.

Together, these layers separate conceptual modeling, package architecture, serialization, implementation, and conformance into independent architectural concerns.

## 5. Fundamental Concepts

The Knowledge Asset Package Specification Suite is organized around the following fundamental concepts.

| Concept | Description |
| --- | --- |
| Subject | The object being described. |
| Asset | The accountable and versioned state of a Subject within a defined Scope. |
| Representation | A structured representation of an Asset intended for publication, exchange or processing. |
| Knowledge | The Subject specialized by the Knowledge Asset Reference Model. |
| Knowledge Asset | An Asset whose Subject is Knowledge. |
| Knowledge Asset Package | An interoperable representation of one published Knowledge Asset version. |
| Content Item | A logical unit of knowledge represented within a Knowledge Asset Package. |

These concepts are formally defined by the normative specifications of the Knowledge Asset Package Specification Suite.

## 6. Architectural Principles

The Knowledge Asset Package Specification Suite is based on the following architectural principles:

- Separation of Assets and Representations
- Organizational Responsibility
- Immutable Publications
- Separation of Logical Organization and Physical Representation
- Technical Validation before Trust Decisions
- Federated Trust
- Interoperability
- Extensibility

These principles provide the architectural foundation for all normative specifications of the Knowledge Asset Package Specification Suite.

## 7. Package Architecture

A Package consists of a small number of complementary architectural components.

A published Package MAY be accompanied by one or more KAP-KDMs for different recipients.

```
Knowledge Asset Package
│
├── Package Manifest
├── Packing List
├── Composition(s)
└── Files

KAP-KDM(s)
    │
    └── reference the Package
```

The Package Manifest references the Packing List and one or more Compositions and protects the integrity of the published Package through its digital signature.

The Packing List defines the physical files contained in the Package.

The Composition defines the logical organization of the represented Knowledge Asset.

KAP-KDMs are independent documents associated with a published Package. They enable authorized recipients to access encrypted Package content but are not part of the Package itself.

Together these components provide a complete, interoperable, and secure representation of a published Knowledge Asset.

## 8. Validation Model

The validation of a received Knowledge Asset Package consists of two independent activities.

```
Package Validation
│
├── Technical Validation
│      ├── Package Structure
│      ├── Package Integrity
│      ├── Digital Signature
│      └── Certificate Chain
│
└── Recipients Decisions
       ├── Issuer Trust
       ├── Product Support
       └── Version Compatibility
```

Technical validation establishes objective and reproducible facts about a Package.

Recipients decisions determine whether a technically valid Package is accepted and processed.

Different organizations MAY legitimately reach different decisions for the same technically valid Package.

## 9. Typical Processing Flow

The following lifecycle illustrates the typical publication, exchange, and consumption of a Knowledge Asset Package.

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/a86ede50-b9f0-4f70-88d7-2be5a66f07d7/pictures/bededbce-b674-4633-b811-f5b40d944749/content_img.png)

This workflow separates publication, technical validation, and organizational acceptance into distinct stages. The actions performed after a Package has been accepted are outside the scope of this specification suite.

## 10. Reading Guide

The following table helps readers identify the most relevant document for their objective.

| Objective | Document |
| --- | --- |
| Understand the General Asset Model | A0 – General Asset Model |
| Understand the Knowledge Asset Model | A1 – Knowledge Asset Reference Model |
| Understand the Package Architecture | S0 – Knowledge Asset Package Architecture Specification |
| Implement Serialization | SC0 – Common Serialization Rules |
| Implement Common Data Types | SC1 – Common Data Types |
| Implement Package Manifest documents | S1 – Package Manifest Schema |
| Implement Packing Lists | S2 – Packing List Schema |
| Implement Compositions | S3 – Composition Schema |
| Implement Key Delivery Messages | S4 – KAP Key Delivery Message Schema |
| Build a Reference Implementation | R0 – Reference Implementation Specification |
| Verify Conformance | T0 – Conformance Test Architecture |
| Implement or Test PKI | T1 – Public Key Infrastructure (PKI) |
| Implement or Test Package Generation | T2 – Package Generation |
| Implement or Test Package Validation | T3 – Package Validation |
| Implement or Test Secure Delivery | T4 – Secure Delivery |
| Verify Interoperability | T5 – Interoperability |

 
