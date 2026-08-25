# S2 – Packing List Schema

Version: 0.9.0
Status: Release Candidate
Type: Normative Schema Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the normative data model, property semantics, validation requirements, and JSON Schema for the Packing List of the KAPRI Specification Suite.

The Packing List provides the complete inventory of all Package Files contained in a Knowledge Asset Package.

For the purposes of this specification, Package Files are the physical Files defined by S0 §4.6.

Package Documents, including manifest.json, packing-list.json and Composition documents, are not Package Files and SHALL NOT be included in the Packing List.

The Packing List enables independent verification of Package File completeness and integrity.

###  

### 1.2 Scope

This specification defines:

- the Packing List data model,
- the semantic meaning of all Packing List properties,
- Packing List-specific validation requirements,
- the normative JSON Schema for the Packing List.

General serialization rules are defined by SC0 – Common Serialization Rules.

Common reusable data types are defined by SC1 – Common Data Types.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Specification Suite.

It builds upon:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types

The Package Manifest defined in S1 – Package Manifest Schema references exactly one Packing List and indirectly protects its integrity through its digitally signed Document Reference.

The semantic organization of Package content is defined separately by S3 – Composition Schema.

## 2 Packing List Overview

### 2.1 Purpose

The Packing List defines the physical inventory of the Package Files contained in a Knowledge Asset Package.

It identifies every Package File together with the metadata required to verify its existence, size and integrity.

### 2.2 Responsibilities

The Packing List provides the information required to:

- identify every Package file contained in the Package,
- locate every Package file within the Package,
- verify file integrity,
- verify package completeness,
- support package processing,
- enable interoperability between independent implementations.

The Packing List defines only the physical inventory of a Package.

It does not define:

- semantic structure,
- relationships between content items,
- publication metadata,
- access control,
- key management.

These aspects are defined by other specifications of the KAPRI Specification Suite.

## 3 Packing List Data Model

### 3.1 Packing List Structure

A Packing List SHALL contain exactly one collection of file entries.

Each file entry represents one physical file contained in the Knowledge Asset Package.

The Packing List SHALL contain the following top-level properties.

| Property | Type | Cardinality |
| --- | --- | --- |
| document_type | String | 1 |
| schema_version | Schema Version | 1 |
| packing_list_id | URI | 1 |
| files | File Entry[] | 1..n |

Each File Entry SHALL contain the following properties.

| Property | Type | Cardinality |
| --- | --- | --- |
| file_id | URI | 1 |
| path | File Path | 1 |
| media_type | Media Type | 1 |
| size | File Size | 1 |
| hash_algorithm | Hash Algorithm | 1 |
| hash | Hash | 1 |
| key_id | Key Identifier | 0..1 |
| annotation | String | 0..1 |

The common data types used by these properties are defined by SC1 – Common Data Types.

### 3.2 Property Semantics

#### 3.2.1 document_type

Identifies the document type.

For a Packing List, this property SHALL contain the value:

```
kap_packing_list
```

#### 3.2.2 schema_version

Identifies the version of the Packing List schema to which this document conforms.

This property enables version-specific validation and interpretation of the Packing List.

#### 3.2.3 packing_list_id

Uniquely identifies the Packing List within the Knowledge Asset Package.

The identifier SHALL be unique within the Package.

#### 3.2.4 files

Contains the complete inventory of all Package Files contained in the Knowledge Asset Package.

Each Package File SHALL be represented by exactly one File Entry.

Package Documents SHALL NOT be included in this collection.

#### 3.2.5 file_id

Uniquely identifies a physical file within the Knowledge Asset Package.

The identifier SHALL be unique within the Packing List.

The file_id is used by other Package components, such as the Composition documents, to reference the corresponding file.

#### 3.2.6 path

Specifies the relative path of the file within the Knowledge Asset Package.

The path SHALL uniquely identify the physical location of the file.

#### 3.2.7 hash

Contains the cryptographic hash value of the referenced file.

The hash enables independent verification of file integrity.

#### 3.2.8 hash_algorithm

Identifies the cryptographic hash algorithm used to calculate the file hash.

Supported algorithms are defined by SC1 – Common Data Types.

#### 3.2.9 size

Specifies the size of the referenced file in bytes.

The value SHALL correspond to the actual file size.

#### 3.2.10 media_type

Identifies the media type of the referenced file.

Media types SHALL be specified using the Internet Media Type (MIME) notation defined by RFC 6838.

#### 3.2.11 annotation

Provides optional human-readable information about the referenced file.

Implementations SHALL NOT depend on the content of this property for automated processing.

#### 3.2.12 key_id

Identifies the symmetric File Key required to decrypt the referenced Package File.
The presence of a key_id indicates that the Package File is encrypted.
The File Key SHALL NOT be contained in the Knowledge Asset Package.

One or more KAP Key Delivery Messages MAY provide an Encrypted File Key associated with this Key Identifier.

The absence of an applicable KAP Key Delivery Message SHALL NOT invalidate the Packing List or the Knowledge Asset Package.

## 4. JSON Representation

### 4.1 General

The Packing List SHALL be represented as a single JSON document.

The serialization of the Packing List SHALL conform to SC0 – Common Serialization Rules.

The document SHALL contain the properties defined in this specification.

### 4.2 Example

The following example illustrates a valid Packing List.

```
{
  "document_type": "kap_packing_list",
  "schema_version": "0.9.0",
  "packing_list_id": "urn:uuid:40b2ca71-39d1-4fae-a365-251a569d699b",
  "files": [
    {
      "file_id": "urn:uuid:b0a2a4a1-cb71-4e79-9b9e-3dad8bce52e6",
      "path": "files/example.md",
      "media_type": "text/markdown",
      "size": 188,
      "hash_algorithm": "SHA-256",
      "hash": "7VTUP_13zmRlEMYpyiR_GF9TH_SZEFzToJwCX2JvFuQ",
      "key_id": "urn:uuid:e82e2e47-615f-4e74-af4d-f5601c2e0cff"
    }
  ]
}
```

## 5. JSON Schema

The normative JSON Schema is provided by the accompanying file:

```
https://inside-workspace.de/kapri/schema/0.9.0/kap_packing_list.schema.json
```

The JSON Schema validates the document structure and primitive data types. Semantic interpretation is defined exclusively by this specification and SC1 – Common Data Types.

Packing List documents SHALL conform to this schema.

In case of discrepancies between this specification and the accompanying JSON Schema, this specification takes precedence.

## 6. Validation Rules

This chapter defines validation requirements specific to the Packing List.

General validation requirements are defined by S0 – Knowledge Asset Package Architecture Specification.

Serialization validation rules are defined by SC0 – Common Serialization Rules.

Validation rules for common data types are defined by SC1 – Common Data Types.

The following additional validation rules apply:

- Exactly one packing_list_id SHALL identify each Packing List.
- Every file_id SHALL be unique within the Packing List.
- Every path SHALL be unique within the Packing List.
- Every referenced file SHALL exist within the Knowledge Asset Package.
- The calculated hash of every referenced file SHALL match the stored hash value.
- The stored size SHALL equal the actual size of the referenced file.
- Every Package File contained in the Knowledge Asset Package SHALL be represented by exactly one File Entry.
- No Package Document SHALL be represented by a File Entry.

## 7. Conformance

### 7.1 General Conformance

An implementation claiming conformance with this specification SHALL satisfy:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- the requirements defined by this specification.

### 7.2 Schema Conformance

Packing List documents SHALL conform to the normative JSON Schema defined by this specification.

### 7.3 Interoperability

Conforming implementations SHALL preserve the semantic meaning of all Packing List properties.

Conforming implementations SHALL interpret Packing List documents consistently and independently of implementation technology.

Conforming implementations SHALL preserve:

- the identity of every physical file,
- the integrity information associated with every file,
- the association between encrypted Package Files and their corresponding Key Identifiers.

 
