# S4 – KAP Key Delivery Message Schema

Version: 0.9.0
Status: Release Candidate
Type: Normative Schema Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the data model, property semantics, validation requirements, and normative JSON Schema for the KAP Key Delivery Message (KAP-KDM) of the KAPRI Specification Suite.

A KAP-KDM is a digitally signed document that provides recipient-specific cryptographic information required to access encrypted content of an existing Knowledge Asset Package.

### 1.2 Scope

This specification defines:

- the KAP-KDM data model,
- the semantics of its properties,
- KAP-KDM-specific validation requirements,
- the normative JSON Schema.

General serialization rules are defined by SC0 – Common Serialization Rules.

Common reusable data types are defined by SC1 – Common Data Types.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Specification Suite.

It builds upon:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types

A KAP-KDM references an existing Knowledge Asset Package but is not part of the Package. It is distributed independently of the Package.

The KAP-KDM provides the recipient-specific cryptographic information required to access encrypted Package content.

Each KAP-KDM contains its own digital signature.

The encrypted files referenced by a KAP-KDM are defined by the Packing List specified in S2 – Packing List Schema.

## 2. Overview

### 2.1 Purpose

A KAP-KDM enables an authorized Recipient to decrypt encrypted files of an existing Knowledge Asset Package.

It provides the Encrypted File Keys required to access protected Package content.

The KAP-KDM identifies both:

- the intended Recipient organization,
- the Recipient Certificate whose public key was used to encrypt the File Keys.

Its digital signature protects the integrity of the KAP-KDM and provides cryptographic evidence of the signer.

### 2.2 Responsibilities

The KAP-KDM provides the information required to:

- identify the referenced Knowledge Asset Package,
- identify the intended Recipient,
- identify the Recipient Certificate used for File Key encryption,
- deliver Encrypted File Keys,
- associate Key Identifiers with Encrypted File Keys,
- enable decryption of protected Package content,
- protect the integrity of the KAP-KDM through a digital signature.

The KAP-KDM does not define:

- publication metadata,
- semantic organization,
- file integrity,
- trust relationships,
- authorization policies.

These aspects are defined by other specifications of the KAPRI Specification Suite or by the receiving implementation.

## 3. Data Model

### 3.1 Structure

A KAP-KDM contains the recipient-specific cryptographic information required to decrypt encrypted files of an existing Knowledge Asset Package.

The following top-level properties are defined:

| Property | Type | Cardinality |
| --- | --- | --- |
| document_type | String | 1 |
| schema_version | Schema Version | 1 |
| kdm_id | URI | 1 |
| package_id | URI | 1 |
| recipient | Organization | 1 |
| recipient_certificate | Certificate Reference | 1 |
| key_entries | Key Entry[] | 1..n |
| signature | Signature | 1 |

Each Key Entry consists of:

| Property | Type | Cardinality |
| --- | --- | --- |
| key_id | Key Identifier | 1 |
| encrypted_file_key | Encrypted File Key | 1 |

The common data types referenced by these properties are defined by SC1 – Common Data Types.

### 3.2 Property Semantics

#### 3.2.1 document_type

Identifies the document as a KAP-KDM.

The value SHALL be:

kap_kdm

#### 3.2.2 schema_version

Identifies the version of this specification used to serialize the KAP-KDM.

Recipients SHALL validate the KAP-KDM according to the specified schema version.

#### 3.2.3 kdm_id

Uniquely identifies the KAP-KDM.

The KAP-KDM Identifier SHALL remain immutable after creation.

#### 3.2.4 package_id

Identifies the Knowledge Asset Package for which the KAP-KDM provides File Keys.

The referenced Package SHALL exist independently of the KAP-KDM.

#### 3.2.5 recipient

Identifies the organization for which the KAP-KDM is intended.

The recipient.organization_id property represents the organizational identity of the receiving party.

The value of recipient.organization_id SHALL exactly match a uniformResourceIdentifier value contained in the Subject Alternative Name extension of the Recipient Certificate.

The recipient.name property provides human-readable information and SHALL NOT be used to establish the correspondence between the Recipient and the Recipient Certificate.

#### 3.2.6 recipient_certificate

Identifies the Recipient Certificate whose public key was used to encrypt the File Keys contained in the KAP-KDM.

The recipient_certificate property SHALL conform to the Certificate Reference data type defined by SC1 – Common Data Types.

The Recipient Certificate SHALL contain a Subject Alternative Name extension with a uniformResourceIdentifier value exactly matching recipient.organization_id.

The Recipient Certificate SHALL be suitable for the File Key encryption scheme defined by the applicable Cryptographic Profile.

Possession of the corresponding Private Key is required to recover the enclosed File Keys.

#### 3.2.7 key_entries

Contains the Encrypted File Keys required to decrypt protected files of the referenced Knowledge Asset Package.

Each Key Entry SHALL associate exactly one Encrypted File Key with exactly one Key Identifier.

Every key_id SHALL correspond to a Key Identifier defined by the Packing List of the referenced Package.

#### 3.2.8 signature

Contains the digital signature protecting the integrity of the KAP-KDM and providing cryptographic evidence that it was signed using the private key corresponding to the signing certificate.

Before signature generation and signature validation, the KAP-KDM SHALL be transformed into its canonical JSON representation according to RFC 8785 – JSON Canonicalization Scheme (JCS).

The signature property SHALL be excluded from the canonical representation.

The signature property SHALL conform to the Signature data type defined by SC1 – Common Data Types.

The signature scheme SHALL be permitted by the applicable Cryptographic Profile.

#### 3.2.9 key_id

Identifies the File Key referenced by the Packing List.

The identifier SHALL correspond to a key_id defined in the Packing List of the referenced Package.

#### 3.2.10 encrypted_file_key

Contains the File Key associated with the referenced Key Identifier, encrypted using the public key of the Recipient Certificate.

The encryption scheme and all parameters required to recover the File Key SHALL be defined by the applicable Cryptographic Profile.

The Encrypted File Key SHALL conform to the Encrypted File Key data type defined by SC1 – Common Data Types.

## 4. JSON Representation

The following example illustrates the structure of a KAP-KDM:

```
{
  "document_type": "kap_kdm",
  "schema_version": "0.9.0",
  "kdm_id": "urn:uuid:69957253-8e3e-48ff-9215-9c5230790f77",
  "package_id": "urn:uuid:3573f619-952d-40d6-bc38-d7f7072ff519",
  "recipient": {
    "organization_id": "urn:kap:organization:kapri-reference-recipient",
    "name": "KAPRI Reference Recipient"
  },
  "recipient_certificate": {
    "certificate_id": "urn:kap:certificate:sha256:...",
    "issuer": "CN=KAPRI Reference Intermediate CA,O=inside workspace GmbH,C=DE",
    "serial_number": "4",
    "certificate": "..."
  },
  "key_entries": [
    {
      "key_id": "urn:uuid:e82e2e47-615f-4e74-af4d-f5601c2e0cff",
      "encrypted_file_key": "..."
    }
  ],
  "signature": {
    "algorithm": "PS256",
    "certificate_chain": [
      {
        "certificate_id": "urn:kap:certificate:sha256:...",
        "issuer": "CN=KAPRI Reference Intermediate CA,O=inside workspace GmbH,C=DE",
        "serial_number": "3",
        "certificate": "..."
      },
      {
        "certificate_id": "urn:kap:certificate:sha256:...",
        "issuer": "CN=KAPRI Reference Root CA,O=inside workspace GmbH,C=DE",
        "serial_number": "2",
        "certificate": "..."
      },
      {
        "certificate_id": "urn:kap:certificate:sha256:...",
        "issuer": "CN=KAPRI Reference Root CA,O=inside workspace GmbH,C=DE",
        "serial_number": "1",
        "certificate": "..."
      }
    ],
    "signature_value": "..."
  }
}
```

The values shown with ... are abbreviated for readability.

The complete Reference KAP-KDM is generated by the KAPRI Reference Implementation using the Reference Cryptographic Profile defined by T1 – Public Key Infrastructure (PKI).

## 5. JSON Schema

The normative JSON Schema for the KAP-KDM is provided by the accompanying file:

kap_kdm.schema.json

Conforming KAP-KDM documents SHALL conform to this schema.

In case of discrepancies between this specification and the accompanying schema, this specification takes precedence.

## 6. Validation Rules

This chapter defines validation requirements specific to the KAP-KDM.

General validation requirements are defined by S0 – Knowledge Asset Package Architecture Specification.

Serialization validation rules are defined by SC0 – Common Serialization Rules.

Validation rules for common data types are defined by SC1 – Common Data Types.

The following additional validation rules apply:

- Exactly one kdm_id SHALL identify each KAP-KDM.
- Exactly one package_id SHALL identify the referenced Knowledge Asset Package.
- Every KAP-KDM SHALL identify exactly one Recipient.
- Every KAP-KDM SHALL identify exactly one Recipient Certificate.
- The Recipient Certificate SHALL correspond to the intended Recipient.
- Every key_id SHALL identify a Key Identifier defined by the Packing List of the referenced Package.
- Every key_id SHALL appear at most once within the KAP-KDM.
- Every Key Entry SHALL contain exactly one Encrypted File Key.
- Every Encrypted File Key SHALL have been encrypted using the public key of the Recipient Certificate.
- Every Encrypted File Key SHALL use an encryption scheme and parameters permitted by the applicable Cryptographic Profile.
- Exactly one signature property SHALL be present in the KAP-KDM.
- The signature property SHALL conform to the Signature data type defined by SC1 – Common Data Types.
- The digital signature SHALL successfully validate the canonical representation of the KAP-KDM using the cryptographic scheme and parameters defined by the applicable Cryptographic Profile.

Successful cryptographic validation of the KAP-KDM does not establish trust in the signer or authorization of the Recipient.

## 7. Conformance

### 7.1 General Conformance

An implementation claiming conformance with this specification SHALL conform to:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- the requirements defined by this specification.

### 7.2 Schema Conformance

KAP-KDM documents SHALL conform to the normative JSON Schema defined by this specification.

### 7.3 Interoperability

Conforming implementations SHALL preserve the semantic meaning of all KAP-KDM properties.

Conforming implementations SHALL interpret KAP-KDM documents consistently and independently of implementation technology.

Conforming implementations SHALL preserve:

- the association between the referenced Knowledge Asset Package and the KAP-KDM,
- the association between the intended Recipient and the Recipient Certificate,
- the association between the Recipient Certificate and the Encrypted File Keys,
- the association between Key Identifiers and Encrypted File Keys,
- the integrity of the KAP-KDM through its digital signature.
