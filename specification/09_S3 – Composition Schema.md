# S3 – Composition Schema

Version: 0.9.0  
Status: Release Candidate  
Type: Normative Schema Specification  
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH  
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the normative data model, property semantics, validation requirements, and JSON Schema for the Composition of the KAPRI Specification Suite.

The Composition defines the logical representation of a Knowledge Asset contained in a Knowledge Asset Package. It organizes Content Items into a coherent semantic structure, defines semantic relationships between them, and provides the bridge between organizational knowledge and the physical files contained in the Package.

### 1.2 Scope

This specification defines:

- the Composition data model,
- the semantic meaning of all Composition properties,
- Composition-specific validation requirements,
- the normative JSON Schema for the Composition.

General serialization rules are defined by SC0 – Common Serialization Rules.
Common reusable data types are defined by SC1 – Common Data Types.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Specification Suite.

It builds upon:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types

The Package Manifest defined in S1 – Package Manifest Schema references one or more Compositions.

The physical files referenced by the Composition are defined by the Packing List specified in S2 – Packing List Schema.

The architectural concepts of Knowledge Assets, Content Items and Files are defined by S0 – Knowledge Asset Package Architecture Specification.

## 2 Composition Overview

### 2.1 Purpose

A Composition defines one logical representation of a Knowledge Asset.

It organizes Content Items into a coherent semantic structure independently of their physical representation within the Package.

A Knowledge Asset Package MAY contain one or more Compositions. Each Composition represents one logical organization of the same Knowledge Asset for a particular purpose, audience, or context.

The Composition provides the bridge between the represented Knowledge Asset and the physical files contained in the Package through the associated Content Items.

### 2.2 Responsibilities

The Composition provides the information required to:

- organize Content Items into a hierarchical structure,
- define semantic relationships between Composition Items,
- associate Content Items with one or more Package files,
- reference external sources,
- enable semantic navigation,
- support consistent interpretation of the represented Knowledge Asset,
- support multiple logical representations of the same Knowledge Asset.

The Composition defines only the logical organization of the represented Knowledge Asset.

It does not define:

- physical file storage,
- file integrity,
- publication metadata,
- digital signatures,
- encryption,
- key management.

These aspects are defined by other specifications of the KAPRI Specification Suite.

## 3 Composition Data Model

### 3.1 Composition Structure

A Composition defines one logical representation of a Knowledge Asset.

A Knowledge Asset Package MAY contain one or more Compositions. Each Composition represents one logical organization of the same Knowledge Asset for a specific purpose, audience, or context.

A Composition consists of two complementary structures:

- Top-level Composition Items, which define the hierarchical organization of the represented Knowledge Asset.
- Relations, which define semantic relationships between Composition Items independently of the hierarchy.

Composition Items MAY recursively contain child Composition Items, thereby forming a recursive hierarchical structure.

Together, the hierarchical structure and the semantic relationships define the logical organization of the represented Knowledge Asset.

A Composition SHALL contain the following top-level properties.

| Property       | Type               | Cardinality |
|----------------|--------------------|-------------|
| document_type  | String             | 1           |
| schema_version | Schema Version     | 1           |
| composition_id | URI                | 1           |
| annotation     | String             | 0..1        |
| items          | Composition Item[] | 1..n        |
| relations      | Relation[]         | 0..n        |


Each Composition Item SHALL contain the following properties.

| Property            | Type               | Cardinality |
|---------------------|--------------------|-------------|
| item_id             | URI                | 1           |
| content_id          | URI                | 0..1        |
| file_ids            | URI[]              | 0..n        |
| external_references | URI[]              | 0..n        |
| items               | Composition Item[] | 0..n        |
| annotation          | String             | 0..1        |

Each Relation SHALL contain the following properties.

| Property       | Type   | Cardinality |
|----------------|--------|-------------|
| relation_id    | URI    | 1           |
| source_item_id | URI    | 1           |
| target_item_id | URI    | 1           |
| relation_type  | String | 1           |
| annotation     | String | 0..1        |

The common data types used by these properties are defined by SC1 – Common Data Types.

### 3.2 Property Semantics

#### 3.2.1 document_type

Identifies the document type.

For a Composition, this property SHALL contain the value:

```
kap_composition
```

#### 3.2.2 schema_version

Identifies the version of the Composition schema to which this document conforms.

This property enables version-specific validation and interpretation of the Composition.

#### 3.2.3 composition_id

Uniquely identifies the Composition within the Knowledge Asset Package.

A Knowledge Asset Package MAY contain multiple Compositions. Each Composition SHALL have a unique identifier.

#### 3.2.4 items

Contains the top-level Composition Items of the Composition.

Top-level Composition Items define the root level of the hierarchical organization of the represented Knowledge Asset.

The order of top-level Composition Items SHALL be preserved.

#### 3.2.5 relations

Contains the semantic relationships between Composition Items.

Each Relation identifies a source Composition Item, a target Composition Item, and the semantic meaning of the relationship.

Relations are independent of the hierarchical organization defined by items.

Together, the hierarchical structure and the Relations define the logical organization of the represented Knowledge Asset.

#### 3.2.6 item_id

Uniquely identifies a Composition Item within the Composition.

The identifier SHALL be unique within the Composition.

Composition Relations SHALL reference Composition Items using their item_id.

#### 3.2.7 content_id

Identifies the Content Item represented by the Composition Item.

A Composition Item MAY reference one Content Item.

The referenced Content Item represents the semantic knowledge associated with the Composition Item.

A Content Item MAY be referenced by multiple Composition Items within the same Composition or by different Compositions of the same Knowledge Asset.

#### 3.2.8 file_ids

References one or more Package Files associated with the referenced Content Item.

Each referenced file SHALL exist in the Packing List.

A Content Item MAY be represented by multiple files.

#### 3.2.9 external_references

References external sources associated with the referenced Content Item.

External references are not part of the Knowledge Asset Package.

Examples include publications, standards, specifications, scientific papers, websites, or other external sources.

#### 3.2.10 items (Composition Item)

Contains the child Composition Items of the current Composition Item.

Child Composition Items define the recursive hierarchical organization of the represented Knowledge Asset.

The order of child Composition Items SHALL be preserved.

#### 3.2.11 relation_id

Uniquely identifies a Relation within the Composition.

The identifier SHALL be unique within the Composition.

#### 3.2.12 source_item_id

Identifies the source Composition Item of a Relation.

The referenced Composition Item SHALL exist within the same Composition.

#### 3.2.13 target_item_id

Identifies the target Composition Item of a Relation.

The referenced Composition Item SHALL exist within the same Composition.

#### 3.2.14 relation_type

Defines the semantic type of the Relation.

Examples include: references, depends_on, illustrates, implements, …

The interpretation of relation_type values is outside the scope of this specification.

#### 3.2.15 annotation (Composition, Composition Item or Relation)

Provides optional human-readable information about a Composition, a Composition Item or Relation.

For a Composition, the annotation MAY describe its purpose, audience, context or intended use.

For a Composition Item, the annotation MAY describe its purpose, role or position within the Composition.

For a Relation, the annotation MAY provide additional human-readable information about the relationship.

Implementations SHALL NOT depend on the content of this property for automated processing.

## 4. JSON Representation

### 4.1 General

The Composition SHALL be represented as a single JSON document.

The serialization of the Composition SHALL conform to SC0 – Common Serialization Rules.

The document SHALL contain the properties defined in this specification.

### 4.2 Example

The following example illustrates a valid Composition.

```
{
  "document_type": "kap_composition",
  "schema_version": "0.9.0",
  "composition_id": "urn:uuid:dce8e84e-8f7d-4671-b26c-875e3dd4c084",
  "items": [
    {
      "item_id": "urn:uuid:9d7aef58-1415-43dc-a7b6-7ebc275acc7a",
      "content_id": "urn:uuid:d2af61f2-d54d-49b4-a9a5-03cd318a8ae2",
      "file_ids": [
        "urn:uuid:b0a2a4a1-cb71-4e79-9b9e-3dad8bce52e6"
      ]
    }
  ]
}
```

## 5. JSON Schema

The normative JSON Schema for the Composition is provided by the accompanying file:

```
https://inside-workspace.de/kapri/schema/0.9.0/kap_composition.schema.json
```

The JSON Schema validates the document structure and primitive data types. Semantic interpretation is defined exclusively by this specification and SC1 – Common Data Types.

Composition documents SHALL conform to this schema.

In case of discrepancies between this specification and the accompanying JSON Schema, this specification takes precedence.

## 6. Validation Rules

This chapter defines validation requirements specific to the Composition.

General validation requirements are defined by S0 – Knowledge Asset Package Architecture Specification.

Serialization validation rules are defined by SC0 – Common Serialization Rules.

Validation rules for common data types are defined by SC1 – Common Data Types.

The following additional validation rules apply:

- Exactly one composition_id SHALL identify each Composition.
- Every item_id SHALL be unique within the Composition.
- Every relation_id SHALL be unique within the Composition.
- Every source_item_id SHALL reference an existing Composition Item.
- Every target_item_id SHALL reference an existing Composition Item.
- source_item_id SHALL NOT equal target_item_id.
- Every content_id, if present, SHALL uniquely identify a Content Item within the represented Knowledge Asset.
- Every referenced file_id SHALL identify an existing file defined by the Packing List.
- The hierarchy of Composition Items SHALL be acyclic.
- Every Composition Item SHALL be reachable from a top-level Composition Item.
- Every Relation SHALL reference Composition Items within the same Composition.
- Every relation_type SHALL be interpreted consistently by all conforming implementations.

## 7. Conformance

### 7.1 General Conformance

An implementation claiming conformance with this specification SHALL satisfy:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- the requirements defined by this specification.

### 7.2 Schema Conformance

Composition documents SHALL conform to the normative JSON Schema defined by this specification.

### 7.3 Interoperability

Conforming implementations SHALL preserve the semantic meaning of all Composition properties.

Conforming implementations SHALL interpret Composition documents consistently and independently of implementation technology.

Conforming implementations SHALL preserve:

- the hierarchical organization defined by items,
- the semantic relationships defined by relations,
- the associations between Composition Items, Content Items, Files, and External References.


