# T4 – Secure Delivery

Version: 0.9.0  
Status: Release Candidate  
Type: Normative Conformance Test Specification  
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH  
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1 Introduction

### 1.1 Purpose

This specification defines the reference process for the secure delivery of File Keys required to access encrypted Knowledge Asset Package content.

Secure Delivery provides recipient-specific cryptographic material required to decrypt encrypted Package Files.

The reference process ensures interoperable delivery and recovery of File Keys while preserving their confidentiality.

### 1.2 Scope

This specification defines:

- recipient-specific File Key encryption,
- KAP-KDM generation,
- KAP-KDM signing,
- KAP-KDM validation,
- File Key recovery,
- Package File decryption.

This specification does not define:

- Package File encryption,
- File Key generation,
- transport protocols,
- certificate management,
- trust management,
- authorization policies,
- long-term key management,
- secure storage of private keys.

Package File encryption and File Key generation are defined by T2 – Package Generation.

### 1.3 Relationship to Other Specifications

This specification forms part of the KAPRI Conformance Test Suite.

It validates requirements defined by:

- S0 – Knowledge Asset Package Architecture Specification
- SC0 – Common Serialization Rules
- SC1 – Common Data Types
- S2 – Packing List Schema
- S4 – KAP Key Delivery Message Schema

Cryptographic algorithms and parameters SHALL conform to the applicable Cryptographic Profile.

The Reference Cryptographic Profile used by the KAPRI Reference Implementation is defined by T1 – Public Key Infrastructure (PKI).

The encrypted Knowledge Asset Package and corresponding File Keys used by the reference process are generated according to T2 – Package Generation.

Package Validation defined by T3 SHALL successfully complete before Package Files are decrypted.

## 2 Secure Delivery

### 2.1 Purpose

Secure Delivery enables an intended Recipient to obtain the symmetric File Keys required to decrypt encrypted Package Files.

For each Recipient, the File Keys are encrypted using the public key of that Recipient's Certificate and delivered through a recipient-specific KAP-KDM.

Possession of the corresponding Private Key is required to recover the File Keys.

### 2.2 Input

The Secure Delivery process requires:

- an encrypted Knowledge Asset Package,
- the File Keys associated with its encrypted Package Files,
- the corresponding Key Identifiers,
- the intended Recipient,
- the Recipient Certificate,
- the Producer Private Key and certification chain required to sign the KAP-KDM.

The Recipient Certificate SHALL correspond to the intended Recipient.

### 2.3 Delivery Workflow

The reference Secure Delivery workflow SHALL consist of the following steps:

```
Encrypted Knowledge Asset Package
+
File Keys
+
Recipient
+
Recipient Certificate
        │
        ▼
Encrypt File Keys for Recipient
        │
        ▼
Generate KAP-KDM
        │
        ▼
Sign KAP-KDM
        │
        ▼
Validate KAP-KDM
        │
        ▼
Recover File Keys
        │
        ▼
Decrypt Package Files
```

Each step SHALL successfully complete before the subsequent step is executed.

### 2.4 Delivery Responsibilities

The Secure Delivery process SHALL ensure that:

- every Encrypted File Key is associated with exactly one Key Identifier,
- every KAP-KDM identifies exactly one intended Recipient,
- every KAP-KDM identifies the Recipient Certificate used for File Key encryption,
- the Recipient Certificate corresponds to the intended Recipient,
- every File Key is encrypted using the public key of the Recipient Certificate,
- every KAP-KDM is digitally signed,
- only possession of the Private Key corresponding to the Recipient Certificate enables recovery of the enclosed File Keys.

Authorization and trust decisions are outside the scope of this specification.

## 3 Conformance Tests

The reference Secure Delivery process SHALL provide the following executable conformance tests.

| Test | Purpose |
| --- | --- |
| T4.1 | Encrypt File Keys for Recipient |
| T4.2 | Generate KAP-KDM |
| T4.3 | Sign KAP-KDM |
| T4.4 | Validate KAP-KDM |
| T4.5 | Recover File Keys |
| T4.6 | Decrypt Package Files |

### T4.1 Encrypt File Keys for Recipient

The test SHALL encrypt each File Key required by the referenced Package using the public key of the Recipient Certificate.

The encryption scheme and all required parameters SHALL conform to the Reference Cryptographic Profile defined by T1 – Public Key Infrastructure (PKI).

Each resulting Encrypted File Key SHALL remain associated with its original Key Identifier.

Expected result: Each File Key required by the Package has a recipient-specific encrypted representation that can only be recovered using the Private Key corresponding to the Recipient Certificate.

### T4.2 Generate KAP-KDM

The test SHALL generate a KAP-KDM conforming to S4 – KAP Key Delivery Message Schema.

The KAP-KDM SHALL:

- identify the referenced Knowledge Asset Package,
- identify the intended Recipient,
- contain the Recipient Certificate,
- contain the required Key Entries,
- preserve the association between each Key Identifier and its Encrypted File Key.

Expected result: A structurally valid recipient-specific KAP-KDM is generated.

### T4.3 Sign KAP-KDM

Before signature generation, the KAP-KDM SHALL be canonicalized according to RFC 8785 – JSON Canonicalization Scheme (JCS).

The signature property SHALL be excluded from the canonical representation.

The canonical representation SHALL be digitally signed using the Producer Private Key and the Reference Cryptographic Profile defined by T1 – Public Key Infrastructure (PKI).

The complete Producer certification chain SHALL be included in the Signature according to SC1 – Common Data Types.

Expected result: The KAP-KDM contains a valid digital signature that can be independently verified using the included certification chain.

### T4.4 Validate KAP-KDM

The test SHALL validate:

- the KAP-KDM structure,
- the referenced Package Identifier,
- the Key Identifiers against the Packing List,
- the intended Recipient,
- the Recipient Certificate,
- the correspondence between Recipient and Recipient Certificate,
- the digital signature,
- the Producer certification chain.

The digital signature SHALL be validated using the cryptographic scheme and parameters defined by the applicable Cryptographic Profile.

Successful cryptographic validation SHALL NOT by itself establish trust in the signer or authorization of the Recipient.

Expected result: The KAP-KDM passes all applicable structural and cryptographic validation requirements.

### T4.5 Recover File Keys

The test SHALL recover the File Keys contained in the KAP-KDM using the Private Key corresponding to the Recipient Certificate.

Each recovered File Key SHALL remain associated with its Key Identifier.

Expected result: All File Keys contained in the KAP-KDM are successfully recovered using the intended Recipient's Private Key.

### T4.6 Decrypt Package Files

The test SHALL use the recovered File Keys to decrypt the corresponding encrypted Package Files.

The association between Package Files and File Keys SHALL be determined through the Key Identifiers defined by the Packing List.

The decryption scheme and all required parameters SHALL conform to the applicable Cryptographic Profile.

Expected result: All applicable Package Files are successfully decrypted.

## 4 Test Execution Order

The Secure Delivery tests SHALL be executed in the following order:

```
T4.1 Encrypt File Keys for Recipient
        ↓
T4.2 Generate KAP-KDM
        ↓
T4.3 Sign KAP-KDM
        ↓
T4.4 Validate KAP-KDM
        ↓
T4.5 Recover File Keys
        ↓
T4.6 Decrypt Package Files
```

Each test depends on the successful completion of all preceding tests.

## 5 Expected Results

The Secure Delivery process SHALL ensure that:

- every KAP-KDM is associated with exactly one Knowledge Asset Package,
- every KAP-KDM identifies exactly one intended Recipient,
- every KAP-KDM identifies the Recipient Certificate used for File Key encryption,
- the Recipient Certificate corresponds to the intended Recipient,
- every Encrypted File Key is correctly associated with its Key Identifier,
- every KAP-KDM is structurally valid,
- every KAP-KDM contains a valid digital signature,
- every File Key can be recovered using the Private Key corresponding to the Recipient Certificate,
- recovered File Keys can successfully decrypt the corresponding Package Files.

Successful Secure Delivery does not establish trust in the Producer or authorization of the Recipient.

## 6 Conformance

An implementation claiming conformance with this specification SHALL:

- generate recipient-specific KAP-KDMs conforming to S4 – KAP Key Delivery Message Schema,
- identify the Recipient Certificate used for File Key encryption,
- preserve the association between File Keys and Key Identifiers,
- encrypt File Keys using the applicable Cryptographic Profile,
- sign KAP-KDMs using the applicable Cryptographic Profile,
- successfully validate generated KAP-KDMs,
- successfully recover all referenced File Keys using the corresponding Recipient Private Key,
- successfully decrypt all applicable Package Files.
