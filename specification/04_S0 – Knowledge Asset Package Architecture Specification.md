# S0 – Knowledge Asset Package Architecture Specification

Version: 0.9.0
Status: Release Candidate
Type: Normative Architecture Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) License.

## 1. Introduction

### 1.1 Purpose

This specification defines the architecture of a Knowledge Asset Package (KAP).

A Knowledge Asset Package is the architectural representation of one published version of one Knowledge Asset, designed for interoperable exchange between independent systems and organizations.

This specification defines the components of that representation, their responsibilities, and their relationships. Their serialization is defined by separate schema specifications.

This specification is normative.

### 1.2 Scope

This specification defines

- the architecture of a Knowledge Asset Package,
- the architectural components of a package,
- the relationships between these components,
- the Package Container, i.e. the physical structure used to store and exchange a Package,
- package lifecycle principles,
- package validation principles,
- and conformance requirements.

This specification does not define

- JSON structures,
- serialization rules,
- cryptographic algorithms,
- certificate infrastructures,
- transport mechanisms,
- implementation technologies.

These subjects are specified separately.

### 1.3 Relationship to Other Specifications

This specification builds upon the following specifications:

- **A0 – General Asset Model**, which defines the architectural concept of an Asset.
- **A1 – Knowledge Asset Reference Model**, which defines Knowledge as the Subject of a Knowledge Asset.

For the purposes of this specification, a Recipient is a Consumer, as defined by A0, that receives a Knowledge Asset Package representing a specific Publication.

The package architecture defined by this specification provides the architectural representation used to exchange published Knowledge Assets.

The concrete serialization of package components is defined by the following schema specifications:

- **S1 – Package Manifest Schema**
- **S2 – Packing List Schema**
- **S3 – Composition Schema**
- **S4 – KAP Key Delivery Message Schema**

## 2. Introduction

Organizations increasingly exchange knowledge across organizational boundaries.
Such exchanges require more than the transfer of documents or files.

Recipients need to understand

- what knowledge is being exchanged,
- who accepts responsibility for it,
- which version is represented,
- whether the package is complete,
- and whether its integrity can be verified.

The Knowledge Asset Package provides a standardized architectural representation for published Knowledge Assets.

A Knowledge Asset Package is not the Knowledge Asset itself. The Knowledge Asset remains the architectural entity defined by the General Asset Model and specialized by the Knowledge Asset Reference Model.

The Package represents one published version of that Knowledge Asset.

Its purpose is to provide a complete, verifiable and interoperable representation suitable for exchange between independent organizations.

### 2.1 Design Objectives

The Package Architecture specializes the General Asset Model and the Knowledge Asset Reference Model for the publication and exchange of Knowledge Assets.

The Package Architecture has been designed according to the following objectives.

#### Architectural Separation

The architecture of a Package is independent of its serialization.

#### Complete Representation

A Package represents exactly one published version of one Knowledge Asset.

#### Interoperability

Independent implementations SHALL be able to exchange Packages without requiring identical internal implementations.

#### Verifiability

The architecture shall enable validation of Package integrity, completeness and authenticity.

#### Extensibility

Future schema versions and serialization formats shall be supported without changing the architectural model.

## 3. Package Overview

A Knowledge Asset Package is the architectural representation of one published Knowledge Asset version.

It consists of a small number of well-defined architectural components.

Each component fulfills one specific responsibility.

Together these components provide a complete representation of the published Knowledge Asset.

The architecture separates

- descriptive information,
- structural information,
- physical content,
- security information,
- and delivery information.

This separation enables independent evolution of package architecture, serialization and implementation technologies.

The conceptual structure of a Knowledge Asset Package is illustrated below.

```
Knowledge Asset Package
│
├── Package Manifest
├── Packing List
├── Compositions
├── Files

Optional: KAP Key Delivery Messages (KAP-KDMs)
```

The architectural semantics of these components are defined by this specification.
Their serialization is defined by separate schema specifications.

## 4. Package Model

A Knowledge Asset Package is composed of a small number of architectural components.

Each component fulfills a single well-defined responsibility.

Together these components provide a complete architectural representation of one published Knowledge Asset Version.

The following components are defined by this specification.

### 4.1 Knowledge Asset Package

A Knowledge Asset Package (KAP), hereafter referred to as the Package, is the architectural representation of one published version of one Knowledge Asset.

A Package combines all architectural components required to identify, interpret, validate and process the published Knowledge Asset.

A Package is immutable after publication.

Any modification of the represented Knowledge Asset SHALL result in the publication of a new Package.

A Package is independent of the storage technology or serialization format used to represent it.

### 4.2 Package Manifest

The Package Manifest describes the published Package as a whole.

It provides the information required to identify the Package, determine its origin and verify its integrity.

The Manifest serves as the primary entry point for Package validation.

The Manifest does not describe the internal structure of the Knowledge Asset.

That responsibility belongs to the Composition.

The serialization of the Manifest is defined by the Package Manifest Schema.

### 4.3 Packing List

The Packing List defines the physical contents of the Package.

It identifies every file belonging to the Package and provides the information required to verify its integrity.

The Packing List establishes the correspondence between the architectural Package and its physical realization.

The Packing List intentionally contains no semantic knowledge about the represented Knowledge Asset.

Its responsibility is limited to the physical inventory of Package contents.

The serialization of the Packing List is defined by the Packing List Schema.

### 4.4 Composition

The Composition defines the logical organization of the represented Knowledge Asset.

It describes how Content Items are organized into a coherent Knowledge Asset.

Unlike the Packing List, the Composition is independent of physical files.

Its responsibility is to describe the semantic structure of the represented organizational knowledge.

The Composition provides the bridge between the Knowledge Asset and the files contained in the Package.

The serialization of the Composition is defined by the Composition Schema.

### 4.5 Content Items

A Content Item represents one logical unit of organizational knowledge contained within a Knowledge Asset.

Content Items form the semantic building blocks of the represented Knowledge Asset.

Examples include

- concepts,
- definitions,
- requirements,
- processes,
- rules,
- models,
- diagrams,
- images,
- datasets,
- or other knowledge elements.

Content Items are identified independently of the files in which they are represented.

A Content Item may be represented by one or more files.

Likewise, a single file may contribute to multiple Content Items where permitted by the Composition.

### 4.6 Files

A File is a physical representation contained within a Package.

Files provide the digital artifacts required to represent Content Items.

The General Asset Model intentionally distinguishes between logical Content Items and physical Files.

Files carry no architectural meaning outside the context established by the Composition.

The Package Architecture intentionally separates semantic structure from physical storage.

### 4.7 KAP Key Delivery Messages

The KAP Key Delivery Message (KAP-KDM) is inspired by the concept of a Key Delivery Message used in Digital Cinema, but is adapted to the requirements defined by this specification.

A KAP-KDM provides the information required to authorize access to encrypted Package contents.

A KAP-KDM does not belong to the represented Knowledge Asset itself.

Instead, it represents delivery information specific to one intended recipient.

Multiple KAP-KDMs may exist for the same published Package.

Each KAP-KDM grants access to the same Package while containing recipient-specific authorization information.

The serialization of a KAP-KDM is defined by the KAP Key Delivery Message Schema.

### 4.8 Digital Signature

A Digital Signature provides cryptographic evidence that the published Package originates from the identified Responsible Organization and has not been modified after publication.

The Digital Signature protects the integrity of the Package Manifest.

The signature does not establish trust in the represented knowledge.

Instead, it enables the Recipient to verify

- the identity of the Responsible Organization,
- the integrity of the published Package,
- and the authenticity of its origin.

Trust in the Responsible Organization remains a decision of the Recipient.

The mechanisms used to generate and validate Digital Signatures are outside the scope of this specification.

### 4.9 Package Container

The Package Container defines the physical structure used to store and exchange a Knowledge Asset Package.

A Knowledge Asset Package SHALL be represented as a directory tree.

The Package Container SHALL consist of one root directory containing the following entries.

| Entry | Content |
| --- | --- |
| manifest.json | The Package Manifest (§4.2), serialized per S1. |
| packing-list.json | The Packing List (§4.3), serialized per S2. |
| compositions/ | One file per Composition (§4.4), serialized per S3. |
| Physical Files (§4.6) | Located at the paths declared by the Packing List, relative to the root directory. |

```
<package-root>/
├── manifest.json
├── packing-list.json
├── compositions/
│   └── <composition-id>.json
└── <path as declared in the Packing List>
```

The paths declared by the Packing List are relative to the root directory; they are not defined relative to any further mandated subdirectory. By convention, the paths of physical Files begin with `files/`, but this specification does not require that convention.

A KAP Key Delivery Message (§4.7) is not part of the Package and therefore SHALL NOT be considered part of the Package Container. A working or delivery directory MAY contain a Package Container alongside a KAP Key Delivery Message or other non-package artifacts without those artifacts becoming part of the Package.

This specification does not define an archive format for the Package Container. A Package Container is exchanged as a directory tree; wrapping it in an archive format (e.g. ZIP, TAR) for a specific transport mechanism is outside the scope of this specification and, where used, SHALL NOT alter the directory structure defined above once unwrapped.

## 5. Package Principles

The architecture of a Knowledge Asset Package is governed by the following principles.

These principles define the normative rules for the architectural components specified by this document.

### 5.1 Package Principle

A Knowledge Asset Package SHALL represent exactly one published version of one Knowledge Asset within its declared publication scope.

A Package SHALL provide all architectural components required to identify, interpret and validate that publication.

### 5.2 Semantic Structure Principle

The semantic organization of a Knowledge Asset SHALL be defined exclusively by the Composition.

The semantic meaning of a Knowledge Asset SHALL be independent of its physical representation.

### 5.3 Physical Storage Principle

The physical contents of a Knowledge Asset Package SHALL be defined exclusively by the Packing List.

The Packing List SHALL describe the physical realization of the Package without defining its semantic structure.

### 5.4 Content Identity Principle

Each Content Item SHALL possess a stable identity independent of its physical representations.

The identity of a Content Item SHALL remain unchanged as long as its semantic meaning remains unchanged.

### 5.5 Representation Principle

A Content Item MAY be represented by one or more physical files.

Changes to physical representations SHALL NOT change the semantic identity of the represented Content Item.

### 5.6 Integrity Principle

A Knowledge Asset Package SHALL support verification of the integrity of all Package components.

Integrity verification SHALL be independent of trust decisions.

### 5.7 Responsibility Principle

Each published Package SHALL identify the organization responsible for the represented Knowledge Asset Version.

Publication SHALL preserve the accountability established by the corresponding Knowledge Asset.

### 5.8 Immutability Principle

A published Knowledge Asset Package SHALL be immutable.

Any modification affecting the published representation SHALL result in a new Package.

### 5.9 Validation Principle

A Knowledge Asset Package SHALL provide all information required for independent validation.

Validation results SHALL be reproducible by conforming implementations.

### 5.10 Interoperability Principle

A conforming Knowledge Asset Package SHALL be exchangeable between independent implementations.

Interoperability SHALL depend exclusively on this specification and the referenced schema specifications.

### 5.11 Separation of Concerns Principle

Each architectural component of a Knowledge Asset Package SHALL have a single well-defined responsibility.

The responsibilities of the Package Manifest, Composition, Packing List, Content Items and Key Delivery Messages SHALL remain distinct.

No architectural component SHALL duplicate the architectural responsibility of another component.

### 5.12 Extensibility Principle

Future versions of the KAPRI Specification Suite MAY introduce additional architectural components, metadata, serialization formats or validation mechanisms.

Such extensions SHALL be explicitly defined by the applicable specification and schema version.

A Knowledge Asset Package SHALL contain only components, properties and values permitted by the applicable specification and schema versions.

Properties or components not defined or explicitly permitted by the applicable versions SHALL cause conformance validation to fail.

### 5.13 Package Container Principle

A Knowledge Asset Package SHALL be represented as a directory tree conforming to the Package Container structure defined in §4.9.

Interoperability of the Package Container SHALL NOT depend on a specific archive or transport format.

## 6. Package Lifecycle

A Knowledge Asset Package represents one published version of one Knowledge Asset.

Unlike the Knowledge Asset itself, a Package does not evolve.

Once published, a Package remains immutable throughout its lifetime.

The lifecycle of a Package therefore describes the stages of publication and exchange rather than the evolution of organizational knowledge.

### 6.1 Package Creation

A Package is created from one approved Knowledge Asset Version.

During package creation, the architectural components defined by this specification are assembled into a complete Knowledge Asset Package.

### 6.2 Package Validation

Before publication, the Package SHALL be validated for structural completeness and integrity.

Validation SHALL ensure that all required architectural components are present and internally consistent.

### 6.3 Package Publication

A validated Package MAY be published.

Publication establishes the immutable representation of the corresponding Knowledge Asset Version.

After publication, the Package SHALL NOT be modified.

### 6.4 Package Distribution

A published Package MAY be distributed to one or more Recipients.

Distribution mechanisms are outside the scope of this specification.

Where required, recipient-specific Key Delivery Messages MAY accompany the Package.

### 6.5 Package Reception and Processing

A Recipient MAY independently validate and process a received Package.

Reception and processing SHALL NOT modify the published Package.

### 6.6 Package Archiving

Published Packages MAY be archived for long-term preservation.

Archived Packages remain valid representations of the published Knowledge Asset Version.

Archival mechanisms are outside the scope of this specification.

Lifecycle Diagramm:

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/fc90bb20-275e-4247-b12c-083726a71051/pictures/15901244-2e8d-409f-97bd-9056bf3316d6/content_img.png)

## 7. Package Validation

A Knowledge Asset Package SHALL provide sufficient information to enable independent evaluation by a Recipient.

The evaluation of a received Package consists of two distinct activities.

The first establishes objective technical facts about the received Package.

The second represents decisions made by the Recipient based on local trust relationships, implementation capabilities and organizational policies.

This specification intentionally separates these activities.

Technical validation produces objective and reproducible results.

Recipient Decisions remain the responsibility of each receiving organization.

### 7.1 Technical Validation

### 7.1 Technical Validation

Technical Validation determines objective properties of the received Package.

For identical Packages, conforming implementations SHALL produce identical validation results.

Technical Validation is independent of organizational policies, trust relationships and implementation preferences.

Technical Validation SHALL include verification of:

- Package Structure,
- Package Integrity,
- Digital Signature,
- Certificate Chain.

Certificate validity SHALL be evaluated as part of Certificate Chain validation.

Every certificate in the certification chain SHALL be valid at the published_at timestamp declared by the Package Manifest.

For this validation, the published_at timestamp SHALL be equal to or later than the certificate's notBefore value and equal to or earlier than its notAfter value.

This validation establishes certificate validity at the declared publication timestamp. It does not establish the actual time at which the digital signature was created.

The detailed validation procedures are defined by the corresponding schema and conformance specifications.

### 7.2 Recipient Decisions

Following successful technical validation, the Recipient determines whether the Package can and should be processed.

These decisions depend on local trust relationships, supported products, supported versions and organizational policies.

This specification intentionally does not prescribe these decisions.

Different Recipients MAY legitimately reach different conclusions for the same technically valid Package.

### 7.3 Validation Categories

The evaluation of a Package consists of the following independent categories.

#### Technical Validation

| Category | Typical Results |
| --- | --- |
| Package Structure | valid / invalid |
| Package Integrity | valid / invalid |
| Digital Signature | valid / invalid |
| Certificate Chain | valid / invalid |

Technical validation establishes objective properties of the received Package.

The results are reproducible and independent of the receiving organization.

#### Recipient Decisions

| Category | Typical Results |
| --- | --- |
| Issuer Trust | trusted / untrusted / unknown |
| Product Support | supported / unsupported / unknown |
| Version Compatibility | compatible / incompatible / unknown |

Recipient Decisions determine whether the receiving organization accepts and processes the Package.
These decisions are local and may legitimately differ between independent Recipients.

### 7.4 Interpretation of Results

Technical validation and Recipient Decisions SHALL be interpreted independently.

A technically valid Package MAY be rejected by a Recipient.

Likewise, trust in an issuer SHALL NOT change the outcome of technical validation.

The acceptance of a Package is therefore determined by the combination of objective validation results and local Recipient Decisions.

This specification defines how objective facts about a Knowledge Asset Package are established. The acceptance and processing of a Package remain the responsibility of each independent Recipient.

## 8. Conformance

This specification defines the architectural requirements for Knowledge Asset Packages.

A conforming implementation SHALL preserve the architectural semantics defined by this specification.

Conformance applies to the architecture of a Knowledge Asset Package and is independent of implementation technologies, serialization formats and deployment models.

### 8.1 General Requirements

A conforming implementation SHALL

- implement the architectural components defined by this specification,
- preserve the responsibilities assigned to each architectural component,
- maintain the separation between semantic structure and physical storage,
- produce and process the Package Container structure defined in §4.9,
- support the package principles defined in this specification,
- support independent Package validation.

### 8.2 Schema Conformance

This specification defines the architecture of a Knowledge Asset Package.

The serialization of individual architectural components is defined by separate schema specifications.

Conformance with this specification therefore requires conformance with the applicable schema specifications.

### 8.3 Recipient Independence

Conforming implementations SHALL perform technical validation independently of local trust decisions.

Recipient-specific trust relationships, product support and version compatibility SHALL remain outside the scope of this specification.

### 8.4 Extensibility

Implementations MAY support extensions introduced by newer versions of the KAPRI Specification Suite.

Extensions SHALL be processed only where they are explicitly permitted by the applicable specification and schema version.

An implementation SHALL NOT interpret unknown properties or components as conforming extensions.

### 8.5 Forward Compatibility

Each Package document SHALL be validated according to its declared schema version.

An implementation that does not support the declared schema version SHALL report the document as unsupported.

It SHALL NOT validate the document against a different schema version or ignore unknown properties or components.

Compatibility between specification and schema versions SHALL be defined explicitly and SHALL NOT be assumed.

 
