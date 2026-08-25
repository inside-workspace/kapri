# SC0 – Common Serialization Rules

Version: 0.9.0
Status: Release Candidate
Type: Normative Common Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the common serialization rules applicable to all schema specifications of the KAPRI Specification Suite.

It establishes a consistent foundation for the serialization, validation and interchange of KAPRI documents.

### 1.2 Scope

This specification defines:

- serialization format,
- character encoding,
- property naming,
- cardinality rules,
- object representation,
- canonical representation,
- schema versioning,
- extensibility rules.

This specification does not define:

- Package-specific properties,
- Package-specific object models,
- common data types,
- cryptographic algorithms or parameters.

### 1.3 Relationship to Other Specifications

This specification is referenced by the schema specifications of the KAPRI Specification Suite, including:

- S1 – Package Manifest Schema
- S2 – Packing List Schema
- S3 – Composition Schema
- S4 – KAP Key Delivery Message Schema

Common reusable data types are defined by SC1 – Common Data Types.

All schema specifications SHALL conform to the serialization rules defined by this specification.

The key words “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” in this specification are to be interpreted as described in RFC 2119.

# 2. Serialization Principles

The following principles apply to all schema specifications.

Serialization SHALL preserve the architectural semantics defined by the corresponding normative specifications.

Serialization SHALL remain independent of implementation technologies.

Conforming implementations SHALL serialize and deserialize KAPRI documents according to this specification and the applicable schema specification.

Serialization SHALL NOT introduce semantic information that is not defined by the corresponding normative specifications.

# 3. Serialization Rules

## 3.1 Serialization Format

Unless otherwise specified by the corresponding normative specification, KAPRI documents SHALL be serialized as JSON documents.

Package Files referenced by KAPRI documents MAY use arbitrary media types as defined by the corresponding specifications.

Future serialization formats MAY be defined by separate specifications without changing the semantic data models defined by the KAPRI Specification Suite.

## 3.2 Character Encoding

All JSON documents defined by the KAPRI Specification Suite SHALL use UTF-8 encoding.

Unicode characters SHALL be preserved without semantic modification.

## 3.3 Property Names

Property names are case-sensitive.

Conforming implementations SHALL use the property names defined by the corresponding schema specification exactly as specified.

Property names SHALL NOT be renamed, normalized or otherwise modified during serialization or deserialization.

## 3.4 Cardinality

Properties SHALL conform to the cardinalities defined by the corresponding data model and schema specification.

Mandatory properties SHALL be present exactly once.

Optional properties MAY be omitted.

Repeated properties SHALL be represented as arrays.

Array cardinalities SHALL conform to the requirements defined by the corresponding schema specification.

## 3.5 Object Representation

Each KAPRI document serialized according to a schema specification SHALL be represented as a single JSON object unless otherwise specified by the corresponding schema specification.

Nested objects and arrays MAY be used where defined by the corresponding schema specification.

Package Files are not subject to this object representation rule unless explicitly specified otherwise.

## 3.6 Property Ordering

The order of JSON object properties SHALL have no semantic meaning.

Conforming implementations SHALL NOT depend on property ordering when interpreting a KAPRI document.

Where deterministic property ordering is required for cryptographic processing, the canonicalization rules defined by this specification SHALL apply.

## 3.7 Unknown Properties

A serialized KAPRI document SHALL contain only properties permitted by the applicable schema version.

Properties not defined or explicitly permitted by the applicable schema SHALL cause schema validation to fail.

Future schema versions MAY introduce additional properties according to the versioning and extensibility rules defined by the corresponding specification.

A receiving implementation SHALL validate a document against the schema version identified by that document.

## 3.8 Canonical Representation

Where deterministic serialization is required for digital signatures or cryptographic hash calculations, JSON documents SHALL be canonicalized according to RFC 8785 – JSON Canonicalization Scheme (JCS), unless explicitly specified otherwise by a normative KAPRI specification.

Canonicalization SHALL operate on the complete JSON value defined as the cryptographic input by the referencing specification.

Properties explicitly excluded from a cryptographic operation SHALL be removed before canonicalization.

For digital signatures of KAPRI documents, the signature property SHALL be excluded before canonicalization where required by the corresponding schema specification.

Canonicalization SHALL NOT alter the semantic content of the serialized document.

Package Files that are not JSON documents SHALL NOT be subject to JSON canonicalization unless explicitly specified otherwise.

## 3.9 Schema Versioning

Every serialized KAPRI document SHALL identify the schema version used for its serialization.

The schema version SHALL be represented by the schema_version property unless otherwise specified by the corresponding schema specification.

Receiving implementations SHALL use the specified schema version to select the applicable schema definition.

A document SHALL be validated according to the schema version identified by the document.

A receiving implementation SHALL NOT silently validate a document against a different schema version.

## 3.10 Extensibility

Future versions of a schema specification MAY introduce additional properties or additional permitted values.

Such extensions SHALL NOT change the semantics of existing properties within the same schema version.

Each document SHALL be validated according to the schema version identified by its schema_version.

A receiving implementation that does not support the specified schema version SHALL NOT interpret the document as conforming to another schema version.

Forward and backward compatibility MAY be defined by the corresponding schema specification.

Support for a newer schema version SHALL NOT be inferred solely from support for an earlier schema version.

# 4. Conformance

This chapter defines the conformance requirements for implementations using the common serialization rules specified by this document.

Conformance with this specification ensures consistent serialization and interpretation of KAPRI documents across the schema specifications of the KAPRI Specification Suite.

## 4.1 General Conformance

Implementations claiming conformance with this specification SHALL serialize and deserialize KAPRI documents in accordance with the requirements defined by this specification.

Implementations SHALL preserve the serialization semantics defined by the corresponding schema specifications.

Implementations SHALL use the schema version identified by a document when validating that document.

## 4.2 Schema Conformance

Schema specifications referencing this specification SHALL conform to the common serialization rules defined by this document.

Schema specifications MAY define additional serialization constraints, provided they do not contradict the requirements of this specification.

A serialized KAPRI document SHALL conform to the normative JSON Schema identified by its schema version.

Properties not permitted by that schema SHALL cause schema validation to fail.

## 4.3 Interoperability

Conforming implementations SHALL interpret serialized KAPRI documents consistently and independently of implementation technology.

Serialization SHALL preserve the semantic meaning defined by the corresponding normative specifications.

Differences in internal data structures, programming languages or implementation technologies SHALL NOT affect the interpretation of a conforming serialized document.

## 4.4 Extensibility and Compatibility

Future versions of this specification MAY introduce additional serialization rules.

Existing serialization rules SHOULD remain backward compatible whenever reasonably possible.

Compatibility between schema versions SHALL be determined explicitly and SHALL NOT be assumed.

An implementation that does not support the schema version identified by a document SHALL report that version as unsupported rather than interpreting the document according to another schema version.

## 4.5 Relationship to Schema Specifications

This specification defines common serialization rules only.

Common reusable data types are defined by SC1 – Common Data Types.

Package-specific object models, properties and validation requirements are defined by the corresponding schema specifications.

Conformance with this specification does not imply conformance with any individual schema specification.

Conformance with a schema specification requires conformance with:

- SC0 – Common Serialization Rules,
- SC1 – Common Data Types, and
- the corresponding schema specification.

Schema specifications MAY impose additional constraints on serialization and validation provided those constraints do not contradict SC0 or SC1.

 
