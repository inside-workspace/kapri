# T1 – Public Key Infrastructure (PKI)

Version: 0.9.0
Status: Release Candidate
Type: Normative Conformance Test Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1 Introduction

### 1.1 Purpose

This specification defines the reference Public Key Infrastructure and Reference Cryptographic Profile used by the KAPRI Reference Implementation and Conformance Test Suite.

The reference PKI provides the certificates required to:

- generate and validate digital signatures of Package Manifests;
- generate and validate digital signatures of KAP Key Delivery Messages;
- encrypt File Keys for intended Recipients;
- recover recipient-specific File Keys.

The Reference Cryptographic Profile defines the cryptographic algorithms, parameters and binary representations required for reproducible and interoperable conformance testing.

### 1.2 Scope

This specification defines:

- the reference certification hierarchy;
- certificate roles;
- certificate constraints;
- the Reference Cryptographic Profile;
- Package File encryption;
- File Key encryption;
- digital-signature parameters;
- certificate generation;
- certificate-chain validation;
- the execution order of PKI conformance tests.

This specification does not define:

- production PKIs;
- trust management;
- certificate revocation;
- timestamp authorities;
- hardware security modules;
- operational security policies;
- long-term key management;
- secure storage of Private Keys.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Conformance Test Suite.

It supports requirements defined by:

- SC1 – Common Data Types;
- S1 – Package Manifest Schema;
- S2 – Packing List Schema;
- S4 – KAP Key Delivery Message Schema;
- T2 – Package Generation;
- T3 – Package Validation;
- T4 – Secure Delivery;
- T5 – Interoperability.

The generated certificates and the Reference Cryptographic Profile are used by the KAPRI Reference Package and the applicable cryptographic conformance tests.

Package File encryption and File Key generation are performed according to T2 – Package Generation.

Recipient-specific encryption and delivery of File Keys are performed according to T4 – Secure Delivery.

The key words “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” in this specification are to be interpreted as described in RFC 2119.

## 2 Reference PKI

### 2.1 Purpose

The reference PKI provides a reproducible certification hierarchy for the KAPRI Reference Implementation.

Its purpose is to enable independent implementations to generate, sign, validate, encrypt and decrypt reference artifacts using interoperable certificates and cryptographic parameters.

The reference PKI is intended exclusively for the Reference Implementation, conformance testing and interoperability testing.

It is not intended for production use.

### 2.2 Reference Certification Hierarchy

The reference certification hierarchy SHALL consist of:

```
Root Certification Authority
        │
        ▼
Intermediate Certification Authority
        │
        ├──────────────────┐
        ▼                  ▼
Producer Certificate   Recipient Certificate
```

The Root Certification Authority SHALL issue the Intermediate Certification Authority Certificate.

The Intermediate Certification Authority SHALL issue:

- Producer Certificates;
- Recipient Certificates.

The Root Certification Authority SHALL NOT directly issue Producer Certificates or Recipient Certificates.

The Intermediate Certification Authority SHALL NOT issue further subordinate Certification Authority certificates.

### 2.3 Certificate Responsibilities

#### 2.3.1 Root Certification Authority

The Root Certification Authority establishes the root of the reference certification hierarchy.

Its Private Key is used to sign the Intermediate Certification Authority Certificate.

The Root Certification Authority Certificate SHALL be self-signed.

#### 2.3.2 Intermediate Certification Authority

The Intermediate Certification Authority issues the end-entity certificates used by the Reference Implementation.

Its Private Key is used to sign:

- Producer Certificates;
- Recipient Certificates.

#### 2.3.3 Producer Certificate

A Producer Certificate identifies the Producer responsible for a cryptographic signature.

The corresponding Producer Private Key is used to sign:

- Package Manifests;
- KAP Key Delivery Messages.

A Producer Certificate SHALL NOT be used to encrypt File Keys.

#### 2.3.4 Recipient Certificate

A Recipient Certificate identifies the intended recipient of Encrypted File Keys contained in a KAP Key Delivery Message.

The public key of the Recipient Certificate is used to encrypt File Keys for that Recipient.

The corresponding Recipient Private Key is used to recover those File Keys.

A Recipient Certificate SHALL NOT be used to sign Package Manifests or KAP Key Delivery Messages.

### 2.4 Reference Cryptographic Profile

The KAPRI Reference Implementation SHALL use the following Reference Cryptographic Profile:

| Purpose | Algorithm or parameter |
| --- | --- |
| Hash Algorithm | SHA-256 |
| Package File Encryption Scheme | A256GCM |
| File Key Length | 256 bits |
| Signature Scheme | PS256 |
| File Key Encryption Scheme | RSA-OAEP-256 |
| RSA Key Size | 3072 bits |

The algorithm identifiers and their cryptographic parameters SHALL be interpreted according to RFC 7518.

The identifier A256GCM denotes AES-GCM using a 256-bit key.

The identifier PS256 denotes RSASSA-PSS using SHA-256 and MGF1 with SHA-256, with a salt length of 32 octets.

The identifier RSA-OAEP-256 denotes RSAES-OAEP using SHA-256 and MGF1 with SHA-256.

Where RSA-OAEP-256 requires a label, the label SHALL be the empty octet sequence.

Hash values, signature values and Encrypted File Keys used by the Reference Cryptographic Profile SHALL use Base64url encoding according to RFC 4648 Section 5 without padding. X.509 certificates SHALL remain encoded according to SC1 – Common Data Types.

The following key algorithm applies to all certificate roles:

- Root Certification Authority: RSA-3072;
- Intermediate Certification Authority: RSA-3072;
- Producer Certificate: RSA-3072;
- Recipient Certificate: RSA-3072.

The cryptographic operation depends on the certificate role:

- Root Certification Authority keys are used to sign Intermediate Certification Authority Certificates;
- Intermediate Certification Authority keys are used to sign Producer Certificates and Recipient Certificates;
- Producer keys are used with PS256 to sign Package Manifests and KAP Key Delivery Messages;
- Recipient public keys are used with RSA-OAEP-256 to encrypt File Keys for a specific Recipient.

Producer Certificates and Recipient Certificates SHALL use separate key pairs.

This separation preserves the distinction between signing and key-encryption responsibilities.

The Reference Cryptographic Profile is a normative requirement for implementations claiming conformance with this specification.

It is a Reference Implementation choice and is not a mandatory Cryptographic Profile for all implementations of the KAPRI Specification Suite.

Conforming implementations MAY use a different Cryptographic Profile outside the Reference Implementation and Conformance Test Suite, provided all participants in a given exchange agree on a profile they mutually support.

An alternative Cryptographic Profile SHALL define all algorithms, parameters and binary representations required for interoperable cryptographic processing.

### 2.4.1 Package File Encryption

The Reference Cryptographic Profile SHALL use A256GCM for Package File encryption.

Each encrypted Package File SHALL use a unique, randomly generated 256-bit File Key.

A fresh, randomly generated 96-bit nonce SHALL be used for every Package File encryption operation.

A nonce SHALL NOT be reused with the same File Key.

The authentication tag length SHALL be 128 bits.

No additional authenticated data SHALL be used.

The complete original Package File SHALL be encrypted as a single byte sequence.

The encrypted Package File SHALL be serialized as the following sequence of octets:

```
magic || nonce || ciphertext || authentication_tag
```

where:

- magic is the eight-octet ASCII sequence KAPENC01;
- nonce is the 12-octet AES-GCM nonce;
- ciphertext is the A256GCM-encrypted representation of the complete original Package File;
- authentication_tag is the 16-octet AES-GCM authentication tag.

The encrypted representation SHALL contain no additional octets.

The ciphertext field MAY have a length of zero octets if the original Package File is empty.

The complete encrypted representation, including magic, nonce, ciphertext and authentication_tag, SHALL constitute the Package File stored in the Knowledge Asset Package.

The hash and File Size recorded in the Packing List SHALL be calculated from this complete encrypted representation.

Decryption SHALL fail if:

- the magic value is not KAPENC01;
- the encrypted representation is malformed;
- or authentication-tag validation fails.

Plaintext produced before successful authentication-tag validation SHALL NOT be processed, returned or otherwise exposed.

### 2.4.2 Digital Signatures

Package Manifests and KAP Key Delivery Messages generated according to the Reference Cryptographic Profile SHALL be signed using PS256.

Before signature generation, the protected JSON document SHALL be canonicalized according to RFC 8785 – JSON Canonicalization Scheme.

The signature property SHALL be excluded from the canonical representation.

The PS256 signature operation SHALL be applied to the resulting canonical representation.

The Signature algorithm property SHALL contain:

```
PS256
```

A receiving implementation SHALL interpret PS256 according to RFC 7518.

A signature using different parameters SHALL NOT be identified as PS256.

The resulting signature value SHALL be Base64url-encoded without padding and serialized as the signature_value property.

### 2.4.3 File Key Encryption

File Keys delivered through a KAP Key Delivery Message SHALL be encrypted using RSA-OAEP-256.

The public key of the intended Recipient Certificate SHALL be used for the encryption operation.

The plaintext input to the RSA-OAEP-256 operation SHALL be exactly the 32-octet File Key used for A256GCM Package File encryption.

No prefix, suffix, encoding or additional metadata SHALL be added to the File Key before encryption.

For an RSA-3072 Recipient public key, the result of the RSA-OAEP-256 encryption operation SHALL be a 384-octet ciphertext.

The RSA-OAEP-256 ciphertext SHALL be Base64url-encoded without padding and serialized as the encrypted_file_key value.

RSA-OAEP-256 decryption SHALL fail if:

- OAEP decoding fails;
- the recovered plaintext is not exactly 32 octets;
- or the required cryptographic parameters do not conform to this profile.

A recovered File Key SHALL NOT be used unless RSA-OAEP-256 decryption has completed successfully.

### 2.5 Certificate Constraints

#### 2.5.1 Root Certification Authority Certificate

The Root Certification Authority Certificate SHALL:

- identify itself as a Certification Authority;
- permit certificate signing;
- permit the issuance of an Intermediate Certification Authority Certificate;
- use an RSA-3072 key pair;
- be self-signed.

#### 2.5.2 Intermediate Certification Authority Certificate

The Intermediate Certification Authority Certificate SHALL:

- identify itself as a Certification Authority;
- permit certificate signing;
- permit the issuance of Producer Certificates and Recipient Certificates;
- prohibit the issuance of further subordinate Certification Authority Certificates;
- use an RSA-3072 key pair;
- be signed by the Root Certification Authority.

#### 2.5.3 Producer Certificate

A Producer Certificate SHALL:

- identify itself as an end-entity certificate;
- permit digital signatures;
- not permit certificate signing;
- not permit key encryption;
- use an RSA-3072 key pair;
- be signed by the Intermediate Certification Authority.

#### 2.5.4 Recipient Certificate

### 2.5.4 Recipient Certificate

A Recipient Certificate SHALL:

- identify itself as an end-entity certificate;
- permit key encryption;
- not permit certificate signing;
- not permit digital signatures for Package Manifests or KAP Key Delivery Messages;
- use an RSA-3072 key pair;
- be signed by the Intermediate Certification Authority;
- contain a Subject Alternative Name extension with a uniformResourceIdentifier value identifying the Recipient organization.

The uniformResourceIdentifier value SHALL be identical to the recipient.organization_id used in a KAP Key Delivery Message for that Recipient.

## 3 Conformance Tests

The reference PKI SHALL provide the following executable conformance tests.

| Test | Purpose |
| --- | --- |
| T1.1 | Generate Root Certification Authority |
| T1.2 | Generate Intermediate Certification Authority |
| T1.3 | Generate Producer Certificate |
| T1.4 | Generate Recipient Certificate |
| T1.5 | Validate Certification Chain |
| T1.6 | Validate Reference Cryptographic Profile |

### T1.1 Generate Root Certification Authority

The test SHALL generate the Root Certification Authority key pair and self-signed certificate.

The generated certificate SHALL conform to the Root Certification Authority constraints defined by this specification.

Expected result: A valid self-signed Root Certification Authority Certificate using an RSA-3072 key pair is generated.

### T1.2 Generate Intermediate Certification Authority

The test SHALL generate the Intermediate Certification Authority key pair and certificate.

The Intermediate Certification Authority Certificate SHALL be signed by the Root Certification Authority and SHALL conform to the applicable certificate constraints.

Expected result: A valid Intermediate Certification Authority Certificate issued by the Root Certification Authority is generated.

### T1.3 Generate Producer Certificate

The test SHALL generate a Producer key pair and Producer Certificate.

The Producer Certificate SHALL be signed by the Intermediate Certification Authority and SHALL conform to the Producer Certificate constraints.

Expected result: A valid Producer Certificate suitable for PS256 Package Manifest and KAP Key Delivery Message signatures is generated.

### T1.4 Generate Recipient Certificate

The test SHALL generate a Recipient key pair and Recipient Certificate.

The Recipient Certificate SHALL be signed by the Intermediate Certification Authority and SHALL conform to the Recipient Certificate constraints.

Expected result: A valid Recipient Certificate suitable for RSA-OAEP-256 File Key encryption is generated.

### T1.5 Validate Certification Chain

The test SHALL validate the complete certification chains of the generated Producer Certificate and Recipient Certificate.

For each certification chain, the test SHALL verify:

- the required chain order;
- certificate signatures;
- issuer and subject correspondence;
- Certification Authority constraints;
- end-entity constraints;
- Key Usage constraints;
- RSA key sizes;
- certificate validity for the validation time defined by the test fixture;
- the self-signature of the Root Certification Authority Certificate.

Expected result: The Producer and Recipient certification chains are structurally and cryptographically valid.

Successful certification-chain validation does not establish trust in the Root Certification Authority or any organization represented by the certificates.

### T1.6 Validate Reference Cryptographic Profile

The test SHALL verify that the Reference Implementation supports:

- SHA-256 hashing;
- A256GCM Package File encryption and decryption;
- PS256 signature generation and validation;
- RSA-OAEP-256 File Key encryption and recovery;
- Base64url encoding without padding for binary JSON values;
- the encrypted Package File representation defined by §2.4.1.

The test SHALL include successful and unsuccessful cryptographic test vectors.

Unsuccessful test vectors SHALL include:

- an altered A256GCM ciphertext;
- an altered A256GCM authentication tag;
- a malformed encrypted Package File;
- a PS256 signature created with non-conforming parameters;
- an RSA-OAEP ciphertext using non-conforming parameters;
- an RSA-OAEP result that does not recover exactly 32 octets.

Expected result: The Reference Implementation accepts conforming cryptographic inputs and rejects non-conforming or unauthenticated inputs.

## 4 Test Execution Order

The executable PKI and profile tests SHALL be executed in the following order:

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/b0bf6bec-c0ab-4e32-8bad-05b8e57e5546/pictures/b68c3333-dc25-4c7e-9421-0b10448d7427/content_img.png)

Each test depends on the successful completion of all preceding tests.

Individual tests MAY be executed independently if their required inputs and prerequisites are provided by an equivalent conforming test fixture.

## 5 Expected Results

The generated certificates SHALL:

- conform to the defined certification hierarchy;
- use RSA-3072 key pairs;
- contain the expected issuer and subject information;
- satisfy the validity period defined by the test fixture;
- contain the required certificate constraints and Key Usage extensions;
- successfully validate as complete certification chains;
- be suitable for their defined cryptographic roles.

Producer Certificates SHALL be suitable for PS256 digital signatures.

Recipient Certificates SHALL be suitable for RSA-OAEP-256 File Key encryption.

The Reference Cryptographic Profile SHALL enable independent implementations to:

- calculate identical SHA-256 hashes for identical inputs;
- encrypt and decrypt Package Files using A256GCM;
- serialize and parse the encrypted Package File format;
- generate and validate PS256 signatures;
- encrypt and recover 256-bit File Keys using RSA-OAEP-256;
- serialize binary cryptographic values consistently.

## 6 Conformance

An implementation claiming conformance with this specification SHALL:

- generate certificates equivalent to the reference PKI;
- preserve the defined certification hierarchy;
- preserve the separation between Producer and Recipient key pairs;
- implement the Reference Cryptographic Profile defined by this specification;
- use the complete cryptographic parameters associated with A256GCM, PS256 and RSA-OAEP-256;
- implement the encrypted Package File representation defined by §2.4.1;
- successfully validate all generated certification chains;
- successfully execute all applicable conformance tests defined by this specification;
- produce interoperable certificates suitable for signing and validating Package Manifests and KAP Key Delivery Messages;
- produce Recipient Certificates suitable for encrypting File Keys;
- reject malformed, unauthenticated or cryptographically non-conforming inputs.

Conformance with this specification demonstrates conformance with the reference PKI and Reference Cryptographic Profile.

It does not establish trust in any certificate, Certification Authority, Producer or Recipient.
