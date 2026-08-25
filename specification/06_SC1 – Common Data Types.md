# SC1 – Common Data Types

Version: 0.9.0
Status: Release Candidate
Type: Normative Common Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This specification defines the reusable data types used throughout the KAPRI Specification Suite.

The defined data types provide a common semantic foundation for all schema specifications and ensure consistent interpretation, serialization and validation across independent implementations.

This specification defines the meaning of each data type independently of any specific Package component.

Package-specific object models, properties and business semantics are defined by the corresponding schema specifications.

### 1.2 Scope

This specification defines:

- reusable common data types,
- their semantic meaning,
- serialization requirements,
- validation requirements.

This specification does not define:

- Package-specific object models,
- Package-specific properties,
- organizational roles,
- business semantics.

The use of the defined data types is specified by the corresponding schema specifications.

### 1.3 Relationship to Other Specifications

This specification is part of the KAPRI Specification Suite.

The common data types defined by this specification are referenced by:

- S1 – Package Manifest Schema
- S2 – Packing List Schema
- S3 – Composition Schema
- S4 – KAP Key Delivery Message Schema

Schema specifications SHALL reuse the data types defined by this specification whenever applicable and SHALL NOT redefine their semantics.

The key words “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” in this specification are to be interpreted as described in RFC 2119.

## 2. Design Principles

The common data types defined by this specification SHALL adhere to the following architectural principles.

### 2.1 Single Responsibility

Each data type SHALL represent exactly one reusable concept.

A data type SHALL NOT combine multiple independent concepts.

### 2.2 Stable Semantics

The semantic meaning of a data type SHALL remain stable across all schema specifications.

The interpretation of a data type SHALL NOT depend on the Package component in which it is used.

### 2.3 Reusability

Common data types SHALL be independent of individual Package components.

The same data type MAY be referenced by multiple schema specifications.

### 2.4 Separation of Data Types and Business Semantics

This specification defines reusable data types only.

Package-specific concepts, organizational roles and business semantics SHALL be defined by the corresponding schema specifications.

### 2.5 Backward Compatibility

Future versions of this specification MAY introduce additional data types.

Existing data types SHALL remain backward compatible whenever reasonably possible.

## 3. Common Data Type Categories

The common data types defined by this specification are organized into logical categories according to their architectural purpose.

### 3.1 Identification Types

Data types used to uniquely identify architectural entities and their versions.

Examples include:

- Identifier
- Version Identifier
- Schema Version

### 3.2 Organization Types

Data types representing organizations participating in the publication or processing of Knowledge Asset Packages.

Examples include:

- Organization

### 3.3 Reference Types

Data types used to reference physical or logical resources.

Examples include:

- URI
- File Path
- Language Tag
- Media Type
- Document Reference

### 3.4 Security Types

Data types supporting integrity and cryptographic verification.

Examples include:

- Hash
- Hash Algorithm
- Signature
- Certificate Reference
- Key Identifier
- Encrypted File Key

### 3.5 Temporal Types

Data types representing points in time and validity intervals.

Examples include:

- Timestamp
- Validity Period

### 3.6 File Types

Data types describing files contained within a Knowledge Asset Package.

Examples include:

- File Identifier
- File Size

## 4. Type Definitions

This chapter defines the reusable common data types referenced by the schema specifications of the KAPRI Specification Suite.

Each data type represents a single architectural concept with stable semantics that are independent of any specific Package component.

The serialization and validation requirements defined for each data type apply wherever that type is referenced by a schema specification.

### 4.1 Identifier

#### Definition

An Identifier uniquely identifies an architectural entity within its defined scope.

#### Semantics

An Identifier provides a stable reference to an entity throughout its lifetime.

The scope and uniqueness requirements of an Identifier are defined by the referencing schema specification.

#### Serialization

An Identifier SHALL be serialized as a JSON string.

#### Validation

The Identifier SHALL conform to the syntax defined by the referencing schema specification.

### 4.2 Version Identifier

#### Definition

A Version Identifier uniquely identifies a specific version of an architectural entity.

#### Semantics

Version Identifiers distinguish different published states of the same entity.

The versioning strategy is defined by the corresponding schema specification or reference model.

#### Serialization

A Version Identifier SHALL be serialized as a JSON string.

#### Validation

The Version Identifier SHALL conform to the syntax defined by the referencing specification.

### 4.3 Schema Version

#### Definition

A Schema Version identifies the version of a schema specification used for serialization and validation.

#### Semantics

Schema Versions enable receiving implementations to select the appropriate schema definition.

#### Serialization

A Schema Version SHALL be serialized as a JSON string.

#### Validation

The Schema Version SHALL identify a published version of the referenced schema.

### 4.4 Organization

#### Definition

An Organization represents a legal or organizational entity participating in the creation, publication or processing of a Knowledge Asset Package.

#### Semantics

This data type represents organizational identity only.

Package-specific organizational roles, such as Responsible Organization, are defined by the corresponding schema specifications.

#### Serialization

An Organization SHALL be serialized as a JSON object.

The internal structure of the object is defined by the referencing schema specification.

#### Validation

An Organization SHALL contain all mandatory properties required by the referencing schema specification.

### 4.5 URI

#### Definition

A Uniform Resource Identifier (URI) identifies a resource using a globally unique identifier.

#### Semantics

A URI provides a standardized reference to a resource outside the semantic structure of the Package.

URIs SHALL conform to RFC 3986.

#### Serialization

A URI SHALL be serialized as a JSON string.

#### Validation

The URI SHALL conform to RFC 3986.

### 4.6 File Path

#### Definition

A File Path identifies the location of a file within a Knowledge Asset Package.

#### Semantics

A File Path is a relative path within the Package.

It identifies the physical location of a serialized file and SHALL NOT be interpreted as a URI.

#### Serialization

A File Path SHALL be serialized as a JSON string using “/” as the path separator.

#### Validation

A File Path:

- SHALL be relative,
- SHALL NOT contain path traversal segments (for example “../”),
- SHALL identify a file contained within the Package.

### 4.7 Language Tag

#### Definition

A Language Tag identifies the natural language associated with textual content.

#### Semantics

Language Tags enable multilingual interoperability.

Language Tags SHALL conform to BCP 47.

#### Serialization

A Language Tag SHALL be serialized as a JSON string.

#### Validation

The Language Tag SHALL conform to BCP 47.

### 4.8 Media Type

#### Definition

A Media Type identifies the representation format of a file or resource.

#### Semantics

Media Types describe the format of serialized resources independently of their semantic meaning.

Media Types SHALL conform to RFC 6838.

#### Serialization

A Media Type SHALL be serialized as a JSON string.

#### Validation

The Media Type SHALL conform to RFC 6838.

### 4.9 Document Reference

#### Definition

A Document Reference identifies a Package document and provides the information required to verify its integrity.

#### Semantics

A Document Reference establishes a stable reference to another document contained in the same Knowledge Asset Package.

It uniquely identifies the referenced document and provides the cryptographic hash required for integrity verification.

#### Structure

A Document Reference SHALL contain the following properties.

| Property | Type | Cardinality |
| --- | --- | --- |
| document_id | URI | 1 |
| hash | Hash | 1 |
| hash_algorithm | Hash Algorithm | 1 |

#### Serialization

A Document Reference SHALL be serialized as a JSON object.

#### Validation

- The referenced document_id SHALL uniquely identify a Package document.
- The hash SHALL correspond to the referenced document.
- The hash_algorithm SHALL identify the algorithm used to calculate the hash.

### 4.10 Hash

#### Definition

A Hash represents the cryptographic digest of serialized data.

#### Semantics

Hashes enable integrity verification by detecting unintended or unauthorized modifications.

The hash value is independent of the algorithm used to calculate it.

#### Serialization

A Hash SHALL be serialized as a JSON string.

The binary hash value SHALL be encoded using Base64url according to RFC 4648 Section 5 without padding.

No whitespace, line breaks or other characters SHALL be included in the encoded value.

#### Validation

The Hash SHALL conform to the syntax required by the selected hash algorithm.

The serialized value SHALL be valid Base64url without padding.

The decoded value SHALL have the length required by the selected Hash Algorithm.

For SHA-256, the decoded Hash SHALL have a length of 32 octets.

### 4.11 Hash Algorithm

#### Definition

A Hash Algorithm identifies the cryptographic algorithm used to calculate a Hash.

#### Semantics

The Hash Algorithm SHALL be permitted by the applicable Cryptographic Profile.

The Hash Algorithm SHALL be supported by the applicable Cryptographic Profile.

#### Serialization

A Hash Algorithm SHALL be serialized as a JSON string.

The serialized value SHALL use the algorithm identifier defined by the applicable Cryptographic Profile.

#### Validation

The algorithm SHALL identify a cryptographic hash algorithm supported by the receiving implementation and permitted by the applicable Cryptographic Profile.

This specification intentionally does not mandate a specific hash algorithm.

The cryptographic algorithms and parameters supported for a given exchange are defined by the applicable Cryptographic Profile.

The Reference Cryptographic Profile used by the KAPRI Reference Implementation is defined by T1 – Public Key Infrastructure (PKI).

### 4.12 Signature

#### Definition

A Signature represents a digital signature providing cryptographic evidence for the integrity of a serialized KAPRI document.

#### Semantics

A Signature provides cryptographic evidence that:

- the protected document has not been modified since it was signed,
- the signature was created using the private key corresponding to the signing certificate,
- the signing certificate can be identified and its certification chain can be cryptographically validated.

A Signature does not by itself establish trust in the organization represented by the associated certificate chain.

Certificate trust, authorization and acceptance decisions are performed independently by the receiving implementation according to its applicable trust policy.

#### Structure

A Signature SHALL contain the following properties.

| Property | Cardinality | Description |
| --- | --- | --- |
| algorithm | 1 | Cryptographic signature scheme used to create the Signature. |
| certificate_chain | 1 | Complete ordered certification chain expressed as an array of Certificate References (1..n), leaf certificate first and Root Certification Authority certificate last. |
| signature_value | 1 | Digital signature over the canonical representation of the protected document. |

The algorithm property SHALL contain the signature algorithm identifier defined by the applicable Cryptographic Profile.

The identifier SHALL determine the complete cryptographic algorithm and all parameters required for signature generation and validation.

For the Reference Cryptographic Profile, the value SHALL be:

```
PS256
```

The identifier PS256 SHALL be interpreted according to RFC 7518.

The signature_value property contains the binary result of the digital-signature operation.

####  

#### Serialization

> A Signature SHALL be serialized as a JSON object.
>
> The signature_value property SHALL be encoded using Base64url according to RFC 4648 Section 5 without padding.
>
> No whitespace, line breaks or other characters SHALL be included in the encoded value.
>
> The certificate_chain property SHALL be serialized according to the Certificate Reference data type defined by §4.13.
>
> X.509 certificates contained in Certificate References SHALL use the certificate encoding defined by §4.13 and SHALL NOT use the Base64url encoding defined for signature_value.

#### Validation

A Signature SHALL contain all mandatory properties defined by this specification.

A Signature SHALL provide all information required to verify:

- the integrity of the protected document,
- the digital signature using the signing certificate,
- the complete cryptographic certification chain.

The algorithm SHALL identify a cryptographic signature scheme supported by the receiving implementation and permitted by the applicable Cryptographic Profile.

This specification intentionally does not mandate a specific signature scheme.

The cryptographic schemes and parameters supported for a given exchange are defined by the applicable Cryptographic Profile.

The Reference Cryptographic Profile used by the KAPRI Reference Implementation is defined by T1 – Public Key Infrastructure (PKI).

The execution and interpretation of cryptographic validation are defined by S0 – Knowledge Asset Package Architecture Specification and the applicable conformance specifications.

### 4.13 Certificate Reference

#### Definition

A Certificate Reference identifies one certificate within a certification chain and embeds the information required for its cryptographic validation without requiring the receiving implementation to retrieve the certificate from an external source.

#### Semantics

A Certificate Reference is self-contained.

It contains the complete certificate together with an identifier and descriptive issuer and serial information.

A Signature's certificate_chain SHALL contain the complete certification chain, including the Root Certification Authority certificate.

The Root Certification Authority certificate is included to make the certification chain self-contained and independently verifiable without requiring external certificate retrieval.

Inclusion of the Root Certification Authority certificate does not imply trust in that Root Certification Authority.

Trust remains an independent decision of the receiving implementation.

An external trust store or PKI is therefore not required for structural and cryptographic chain validation.

A receiving implementation MAY use an external trust store or other trust information when making trust decisions.

#### Structure

A Certificate Reference SHALL contain the following properties.

| Property | Type | Cardinality |
| --- | --- | --- |
| certificate_id | URI | 1 |
| issuer | String | 1 |
| serial_number | String | 1 |
| certificate | String | 1 |

#### Property Semantics

**certificate_id**

A stable identifier for the referenced certificate.

The identifier enables comparison, referencing and caching without requiring the certificate to be parsed.

**issuer**
The Distinguished Name of the Certification Authority that issued the referenced certificate, serialized according to RFC 4514.

The property is provided for inspection and logging and SHALL NOT be used as a substitute for cryptographic certificate validation.

**serial_number**
The serial number of the referenced certificate, as assigned by the issuing Certification Authority, serialized as a decimal string.

**certificate**
The complete X.509 certificate in DER encoding, Base64-encoded according to RFC 4648 Section 4 using the standard alphabet with padding.

#### Serialization

A Certificate Reference SHALL be serialized as a JSON object containing the properties defined above.

#### Validation

The certificate property SHALL decode to a syntactically valid DER-encoded X.509 certificate.

The issuer property SHALL correspond to the issuer encoded in the embedded certificate.

The serial_number property SHALL correspond to the serial number encoded in the embedded certificate.

A certificate_chain SHALL contain the complete certification chain and SHALL be ordered leaf certificate first.

For each certificate except the last:

- its issuer SHALL correspond to the subject of the following certificate,
- its signature SHALL validate using the public key of the following certificate.

The last certificate in the chain SHALL be the Root Certification Authority certificate.

The Root Certification Authority certificate SHALL be self-signed: its subject SHALL equal its issuer and its signature SHALL validate using its own public key.

Successful structural and cryptographic validation of a certification chain does not establish trust in the Root Certification Authority or any other certificate in the chain.

### 4.14 Encrypted File Key

#### Definition

An Encrypted File Key represents a symmetric File Key encrypted for one intended Recipient.

#### Semantics

An Encrypted File Key contains the encrypted symmetric key required to decrypt one encrypted Package File.

Each Encrypted File Key SHALL be associated with exactly one Key Identifier.

The encrypted value is Recipient-specific and SHALL NOT be interpreted outside the context of the corresponding KAP Key Delivery Message.

The encryption scheme and all parameters required to recover the File Key SHALL be defined by the applicable Cryptographic Profile.

#### Serialization

An Encrypted File Key SHALL be serialized as a JSON string.

The binary result of the File Key encryption operation SHALL be encoded using Base64url according to RFC 4648 Section 5 without padding.

No whitespace, line breaks or other characters SHALL be included in the encoded value.

The decoded binary value SHALL be interpreted according to the File Key encryption scheme defined by the applicable Cryptographic Profile.

For the Reference Cryptographic Profile, the decoded value SHALL be an RSA-OAEP-256 ciphertext.

When an RSA-3072 Recipient public key is used, the decoded ciphertext SHALL have a length of 384 octets.

#### Validation

An Encrypted File Key SHALL be valid Base64url without padding.

The decoded value SHALL conform to the File Key encryption scheme and parameters defined by the applicable Cryptographic Profile.

The encryption scheme used to create the Encrypted File Key SHALL be supported by the receiving implementation and permitted by the applicable Cryptographic Profile.

This specification intentionally does not mandate a specific File Key encryption scheme.

The cryptographic schemes and parameters supported for a given exchange are defined by the applicable Cryptographic Profile.

The Reference Cryptographic Profile used by the KAPRI Reference Implementation is defined by T1 – Public Key Infrastructure (PKI).

Cryptographic decryption and validation of the recovered File Key are outside the scope of this data type.

### 4.15 Key Identifier

#### Definition

A Key Identifier uniquely identifies a symmetric File Encryption Key.

#### Semantics

A Key Identifier provides a stable reference to a symmetric File Key independently of how that File Key is distributed or encrypted.

The corresponding Encrypted File Key MAY be delivered by one or more KAP Key Delivery Messages.

#### Serialization

A Key Identifier SHALL be serialized as a URI.

#### Validation

A Key Identifier SHALL conform to RFC 3986.

### 4.16 Timestamp

#### Definition

A Timestamp represents a single point in time.

#### Semantics

Timestamps describe publication, creation or validation events.

Unless otherwise specified, timestamps SHALL be expressed in Coordinated Universal Time (UTC).

#### Serialization

A Timestamp SHALL be serialized according to ISO 8601.

#### Validation

The Timestamp SHALL conform to ISO 8601.

### 4.17 Validity Period

#### Definition

A Validity Period defines the interval during which an entity is considered valid.

#### Semantics

A Validity Period consists of a mandatory start timestamp and an optional end timestamp.

#### Serialization

A Validity Period SHALL be serialized as an object containing the defined timestamps.

#### Validation

If an end timestamp is present, it SHALL NOT precede the start timestamp.

### 4.18 File Identifier

#### Definition

A File Identifier uniquely identifies a file within a Knowledge Asset Package.

#### Semantics

A File Identifier provides a stable reference to a file independent of its physical location or file name.
A File Identifier remains stable even if the corresponding File Path changes.

#### Serialization

A File Identifier SHALL be serialized as a JSON string.

#### Validation

The File Identifier SHALL conform to the syntax defined by the referencing schema specification.

### 4.19 File Size

#### Definition

A File Size represents the size of a serialized file in octets.

#### Semantics

File Size supports completeness and integrity verification.

#### Serialization

A File Size SHALL be serialized as a non-negative integer.

#### Validation

A File Size SHALL be greater than or equal to zero.

## 5. Serialization Requirements

This chapter defines the serialization requirements applicable to the common data types defined by this specification.

The general serialization rules are specified by SC0 – Common Serialization Rules.

Schema specifications referencing the data types defined by this specification SHALL serialize them in accordance with both SC0 and the requirements defined in this chapter.

### 5.1 General Requirements

Common data types SHALL be serialized using the rules defined by SC0.

Each data type SHALL have exactly one serialized representation for a given applicable schema version and Cryptographic Profile.

Serialization SHALL preserve the semantic meaning of the referenced data type.

### 5.2 Identifier Types

Identifier Types SHALL be serialized as JSON strings.

The serialized representation SHALL preserve the identifier value exactly as defined by the referencing schema specification.

Serialization SHALL NOT modify, normalize or truncate identifier values.

### 5.3 Organization Types

Organization Types SHALL be serialized as JSON objects.

The internal structure of an Organization is defined by the referencing schema specification.

The serialized representation SHALL be independent of any package-specific organizational role.

### 5.4 Reference Types

Reference Types SHALL use their standardized serialized representation.

Where applicable:

- URIs SHALL conform to RFC 3986.
- Language Tags SHALL conform to BCP 47.
- Media Types SHALL conform to RFC 6838.

File Paths SHALL:

- be serialized as relative JSON strings,
- use “/” as the path separator,
- identify locations within the Package.

### 5.5 Security Types

Security Types SHALL be serialized using the representations defined by this specification.

Hash values, Signature Values and Encrypted File Keys SHALL use Base64url encoding according to RFC 4648 Section 5 without padding.

X.509 certificates contained in Certificate References SHALL use Base64 encoding according to RFC 4648 Section 4 with padding.

The cryptographic interpretation of each binary value SHALL be determined by the applicable Cryptographic Profile.

The canonical representation used for digital signatures SHALL be defined by the referencing schema specification in accordance with SC0 – Common Serialization Rules.

### 5.6 Temporal Types

Timestamp values SHALL be serialized according to ISO 8601.

Unless otherwise specified, timestamps SHALL represent Coordinated Universal Time (UTC).

Validity Periods SHALL consist of a mandatory start timestamp and an optional end timestamp.

### 5.7 File Types

File Identifiers SHALL be serialized as JSON strings.

File Sizes SHALL be serialized as non-negative integer values representing the number of octets.

## 6. Validation Requirements

This chapter defines the validation requirements applicable to the common data types defined by this specification.

Validation performed according to this specification verifies the structural and syntactic correctness of the serialized data types.

Execution of Package-level semantic and cryptographic validation, trust decisions, authorization policies and interoperability checks is defined by the corresponding schema specifications, S0 – Knowledge Asset Package Architecture Specification and the applicable conformance specifications.

### 6.1 General Requirements

Every serialized data type SHALL conform to the validation requirements defined by this specification.

Validation of a data type SHALL be independent of the Package component in which it is used.

Failure to validate a referenced data type SHALL cause validation of the containing object to fail.

### 6.2 Identifier Types

Identifier Types SHALL conform to the syntax defined by the referencing schema specification.

Where uniqueness is required, the corresponding schema specification SHALL define the applicable scope.

### 6.3 Organization Types

Organization Types SHALL contain all mandatory information required by the referencing schema specification.

Validation of organizational roles and responsibilities is outside the scope of this specification.

### 6.4 Reference Types

Reference Types SHALL conform to the applicable standards.

Where applicable:

- URIs SHALL conform to RFC 3986.
- Language Tags SHALL conform to BCP 47.
- Media Types SHALL conform to RFC 6838.

File Paths:

- SHALL be relative,
- SHALL NOT contain path traversal segments such as ..,
- SHALL identify files located within the Package.

### 6.5 Security Types

Hash values SHALL:

- be valid Base64url without padding;
- decode to the length required by the selected Hash Algorithm.

Signature objects SHALL conform to the structure defined by §4.12.

Signature Values SHALL:

- be valid Base64url without padding;
- decode to a binary signature compatible with the selected signature algorithm and key size.

Certificate References SHALL conform to §4.13.

Encrypted File Keys SHALL:

- be valid Base64url without padding;
- decode to a ciphertext compatible with the File Key encryption scheme and key size defined by the applicable Cryptographic Profile.

### 6.6 Temporal Types

Timestamp values SHALL conform to ISO 8601.

Validity Periods SHALL contain a mandatory start timestamp.

If an end timestamp is present, it SHALL NOT precede the start timestamp.

### 6.7 File Types

File Identifiers SHALL conform to the syntax defined by the referencing schema specification.

File Sizes SHALL be non-negative integer values representing the size of the serialized file in octets.

## 7. Conformance

This chapter defines the conformance requirements for implementations using the common data types specified by this specification.

Conformance to this specification ensures that common data types are interpreted, serialized and validated consistently across all schema specifications of the KAPRI Specification Suite.

### 7.1 General Conformance

An implementation claiming conformance with this specification SHALL implement every common data type referenced by the schema specifications it supports.

Referenced data types SHALL be interpreted, serialized and validated in accordance with:

- SC0 – Common Serialization Rules, and
- this specification.

### 7.2 Referenced Data Types

Schema specifications SHALL reuse the common data types defined by this specification whenever applicable.

Schema specifications SHALL NOT alter the semantics of a referenced common data type.

Additional constraints MAY be defined by the referencing schema specification, provided they do not contradict this specification.

### 7.3 Consistent Interpretation

Conforming implementations SHALL interpret common data types consistently across all KAPRI documents.

The semantic meaning of a common data type SHALL be independent of the schema specification in which it is referenced.

### 7.4 Extensibility

Future versions of this specification MAY introduce additional common data types.

Existing data types SHOULD remain backward compatible whenever reasonably possible.

An implementation that does not support a data type required by the applicable schema specification SHALL report the data type as unsupported.

It SHALL NOT interpret a value using a different data type or representation.

### 7.5 Relationship to Schema Specifications

This specification defines reusable common data types only.

Package-specific object models, properties, validation rules and business semantics are defined by the corresponding schema specifications.

Conformance with this specification does not imply conformance with any individual schema specification.

Conformance with a schema specification requires conformance with:

- SC0 – Common Serialization Rules,
- SC1 – Common Data Types, and
- the referenced schema specification.

Schema specifications SHALL reuse the common data types defined by this specification rather than redefining equivalent data types.

 
