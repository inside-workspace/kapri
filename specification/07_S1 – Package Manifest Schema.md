# S1 – Package Manifest Schema

Version: 0.9.0
Status: Release Candidate
Type: Normative Schema Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the data model, semantics, validation requirements and normative JSON Schema for the Package Manifest of the KAPRI Specification Suite.

The Package Manifest is the authoritative entry document of every Knowledge Asset Package. It identifies the published Knowledge Asset version, describes the publication context, references all Package components and provides the information required to verify the integrity of the Package and the digital signature of the Producer.

### 1.2 Scope

This specification defines:

- the Package Manifest data model,
- the semantics of all Manifest properties,
- Package Manifest-specific validation requirements,
- the normative JSON representation,
- the normative JSON Schema,
- the conformance requirements for Producers and Recipients.

This specification does not define:

- the Packing List structure (see S2),
- the Composition structure (see S3),
- the Key Delivery Message (see S4),
- certificate management,
- trust management,
- key management,
- long-term signature validation.

General serialization rules are defined by SC0 – Common Serialization Rules.

Common reusable data types are defined by SC1 – Common Data Types.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Specification Suite.

It builds upon:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types

The Package Manifest references additional Package components specified by:

- S2 – Packing List Schema
- S3 – Composition Schema

The Key Delivery Message specified by S4 – KAP Key Delivery Message Schema is not part of the Knowledge Asset Package and is therefore not referenced by the Package Manifest.

## 2. Package Manifest Overview

### 2.1 Purpose

The Package Manifest is the authoritative description of a published Knowledge Asset Package.

Every Knowledge Asset Package SHALL contain exactly one Package Manifest.

The Package Manifest provides the information required to:

- identify the Package,
- identify the published Knowledge Asset version,
- identify the organizations responsible for publication,
- identify the Producer through the associated certificate chain,
- define the publication scope,
- define the validity period, if applicable,
- reference all Package components,
- protect the integrity of the complete Knowledge Asset Package through a digital signature.

### 2.2 Manifest Lifecycle

The Package Manifest is created as part of Package generation.

Before publication, all mandatory Manifest properties SHALL be completed and the Manifest SHALL be digitally signed by the Producer.

After publication, the Package Manifest SHALL remain immutable.

Any modification requires the generation and publication of a new Knowledge Asset Package with a new Package Identifier and a new digital signature.

### 2.3 Manifest Responsibilities

The digital signature protects the canonical representation of the Package Manifest.

Since the Manifest references the Packing List and all Compositions through cryptographic hashes, the digital signature establishes a cryptographically protected integrity chain from the signed Manifest to every referenced Package component.

Recipients SHALL validate the Manifest before processing any referenced Package component.

## 3. Manifest Data Model

### 3.1 Package Manifest Structure

The Package Manifest SHALL contain the following properties.

| Property | Type | Cardinality |
| --- | --- | --- |
| document_type | String | 1 |
| schema_version | Schema Version | 1 |
| package_id | URI | 1 |
| knowledge_asset_id | URI | 1 |
| knowledge_asset_version_id | Version Identifier | 1 |
| knowledge_asset_version_label | String | 1 |
| title | String | 1 |
| publication_scope | Publication Scope | 1 |
| responsible_organization | Organization | 1 |
| published_at | Timestamp | 1 |
| validity | Validity Period | 0..1 |
| packing_list | Document Reference | 1 |
| compositions | Document Reference[] | 1..n |
| signature | Signature | 1 |

### 3.2 Property Semantics

The following clauses define the normative semantics of each Package Manifest property.

#### 3.2.1 document_type

Identifies the document as a Package Manifest.

The value SHALL be

```
kap_manifest
```

#### 3.2.2 schema_version

Identifies the version of this specification used to serialize the Manifest.

Recipients SHALL validate the Manifest according to the specified schema version.

#### 3.2.3 package_id

Uniquely identifies the Knowledge Asset Package.

The Package Identifier SHALL remain immutable after publication.

#### 3.2.4 knowledge_asset_id

Identifies the Knowledge Asset represented by the Package.

Multiple published versions of the same Knowledge Asset SHALL use the same knowledge_asset_id.

#### 3.2.5 knowledge_asset_version_id

Uniquely identifies the published version of the Knowledge Asset.

Every published version SHALL have a different Version Identifier.

#### 3.2.6 knowledge_asset_version_label

Provides a human-readable version label.

The label is intended for display purposes and SHALL NOT be used for version comparison.

#### 3.2.7 title

Provides a human-readable title of the published Knowledge Asset version.

#### 3.2.8 publication_scope

Defines whether the Package represents the complete Knowledge Asset or only a published subset.

#### 3.2.9 responsible_organization

Identifies the organization that publishes the Package and assumes responsibility for the published Knowledge Asset version.

#### 3.2.10 published_at

Specifies the publication timestamp of the Package.

#### 3.2.11 validity

Optionally defines the validity period of the published Knowledge Asset version.

#### 3.2.12 packing_list

References the Package Packing List using a Document Reference.

The referenced hash SHALL be used during integrity validation.

#### 3.2.13 compositions

References one or more Composition documents using Document References.

Every referenced Composition SHALL be included in the Package.

#### 3.2.14 signature

Contains the digital signature protecting the integrity of the Package Manifest and providing cryptographic evidence that it was signed using the private key corresponding to the Producer Certificate.

Before signature generation and signature validation, the Package Manifest SHALL be transformed into its canonical JSON representation according to RFC 8785 – JSON Canonicalization Scheme (JCS). The signature property SHALL be excluded from the canonical representation.

The signature property SHALL conform to the Signature data type defined by SC1 – Common Data Types.

The signature algorithm SHALL be permitted by the applicable Cryptographic Profile.

## 4. JSON Representation

### 4.1 General

The Package Manifest SHALL be represented as a single JSON document.

The serialization of the Package Manifest SHALL conform to SC0 – Common Serialization Rules.

The document SHALL contain the properties defined in this specification.

### 4.2 Example

The following example illustrates a valid Package Manifest.

```
{
  "document_type": "kap_manifest",
  "schema_version": "0.9.0",
  "package_id": "urn:uuid:3573f619-952d-40d6-bc38-d7f7072ff519",
  "knowledge_asset_id": "urn:uuid:b5919822-7095-44bb-85d1-3a9513b894ad",
  "knowledge_asset_version_id": "urn:uuid:d67c5911-727d-4fa7-94cb-95083d874b16",
  "knowledge_asset_version_label": "1.0",
  "title": "KAPRI Reference Package",
  "publication_scope": "complete",
  "responsible_organization": {
    "organization_id": "urn:kap:organization:kapri-reference",
    "name": "KAPRI Reference Organization"
  },
  "published_at": "2026-08-08T08:56:16Z",
  "packing_list": {
    "document_id": "urn:uuid:40b2ca71-39d1-4fae-a365-251a569d699b",
    "hash_algorithm": "SHA-256",
    "hash": "k4tx0lwKkz4PFpWudkXGEzllN2wLZXMrf07cyKyVAio"
  },
  "compositions": [
    {
      "document_id": "urn:uuid:dce8e84e-8f7d-4671-b26c-875e3dd4c084",
      "hash_algorithm": "SHA-256",
      "hash": "qVZ8NMwbHjWXNke3qac-nZhGGiiGRPWzCyNw0kcfP4I"
    }
  ],
  "signature": {
    "algorithm": "PS256",
    "certificate_chain": [
    ],
    "signature_value": "MEYCIQDNJzN8ab4s_Bg3R8qv5WyOwqL7eAg6XXvUC6Fj9RRNhAIhAKAkIfEe5JLML-9n46u7eMghl_1Sri05FOi1Dw8DuHh7"
  }
}
```

## 5. JSON Schema

The normative JSON Schema for the Package Manifest is provided by the accompanying file:

```
https://inside-workspace.de/kapri/schema/0.9.0/kap_manifest.schema.json
```

The JSON Schema validates the document structure and primitive data types. Semantic interpretation is defined exclusively by this specification and SC1 – Common Data Types.

Package Manifest documents SHALL conform to this schema.

In case of discrepancies between this specification and the accompanying JSON Schema, this specification takes precedence.

## 6. Validation Rules

This chapter defines validation requirements specific to the Package Manifest.

General validation requirements are defined by S0 – Knowledge Asset Package Architecture Specification.

Serialization validation rules are defined by SC0 – Common Serialization Rules.

Validation rules for common data types are defined by SC1 – Common Data Types.

The following additional validation rules apply:

- Exactly one Package Manifest SHALL be present in every Knowledge Asset Package.
- Exactly one signature property SHALL be present in the Package Manifest.
- The referenced Packing List SHALL exist within the Package.
- At least one referenced Composition SHALL exist within the Package.
- Every referenced document SHALL successfully pass integrity verification.
- The signature property SHALL conform to the Signature data type defined by SC1 – Common Data Types.
- The digital signature SHALL successfully validate the canonical representation of the Package Manifest using the cryptographic scheme and parameters defined by the applicable Cryptographic Profile.

## 7. Conformance

### 7.1 General

An implementation claiming conformance with this specification SHALL conform to:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- this specification.

### 7.2 Schema Conformance

Package Manifest documents SHALL conform to the normative JSON Schema defined by this specification.

### 7.3 Interoperability

Conforming implementations SHALL preserve the semantic meaning of all Package Manifest properties.

Conforming implementations SHALL interpret Package Manifest documents consistently and independently of implementation technology.

 
