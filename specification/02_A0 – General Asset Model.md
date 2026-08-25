# A0 – General Asset Model

Version: 0.9.0
Status: Release Candidate
Type: Normative Model Specification
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) Licence.

## 1. Introduction

### 1.1 Purpose

This document defines the General Asset Model (GAM).

The General Asset Model establishes the fundamental architectural concepts required to describe, manage and exchange versioned Assets independently of any application domain or implementation technology.

It provides the common conceptual foundation for all specifications belonging to the KAPRI Specification Suite.

This specification is normative.

### 1.2 Scope

This specification defines

- the core concepts of the General Asset Model,
- the relationships between these concepts,
- the architectural principles governing Assets,
- the lifecycle concepts of Assets,
- the conformance requirements of this specification.

This specification does not define

- domain-specific Asset types,
- serialization formats,
- metadata schemas,
- package structures,
- cryptographic mechanisms,
- transport protocols,
- implementation technologies.

These subjects are defined by separate specifications.

### 1.3 Audience

This specification is intended for:

- architects designing Asset-based information infrastructures,
- software developers implementing Asset-based systems,
- platform providers supporting Asset exchange,
- standards authors defining domain-specific Asset models,
- organizations publishing, exchanging, or consuming Assets.

### 1.4 Conformance

The key words MUST, MUST NOT, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY, and OPTIONAL in this specification are to be interpreted as described in RFC 2119.

An implementation claiming conformance with this specification SHALL satisfy all normative requirements defined by this specification.

## 2. Introduction

Organizations continuously create descriptions of subjects such as products, services, processes, regulations, software, designs, and knowledge.

These descriptions evolve over time.

New information becomes available, decisions are revised, errors are corrected, and responsibilities change.

Consequently, the description of a subject cannot be regarded as static. Instead, it represents a sequence of documented States reflecting the current understanding of that subject at different points in time.

Managing these States consistently becomes increasingly important as information is published, exchanged between organizations, reused across systems, or processed automatically.

Such scenarios require more than the storage of information.

They require:

- explicit organizational responsibility,
- controlled versioning,
- defined scope,
- traceable evolution,
- stable semantics independent of individual representations.

The General Asset Model (GAM) introduces a conceptual framework that addresses these requirements.

Rather than treating documents, files, databases, or other technical artifacts as the primary unit of management, the model defines an Asset as the responsible and versioned State of a Subject within a defined Scope.

Documents, databases, Packages, and other artifacts are therefore not Assets themselves.

They are Representations of an Asset.

This distinction separates the managed subject matter from the technical forms in which it is stored, exchanged, or presented.

The General Asset Model intentionally remains independent of any specific application domain.

Domain-specific Asset Reference Models define how the concepts introduced by the General Asset Model apply to particular subjects such as knowledge, software, processes, or designs.

### 2.1 Design Objectives

> The General Asset Model is designed to support independently evolving specialized Asset Reference Models through the following architectural objectives.

#### Domain Independence

The architectural concepts defined by this specification SHALL be applicable across different application domains without modification.

#### Technology Independence

The model SHALL remain independent of storage technologies, exchange formats, programming languages, communication protocols, and implementation technologies.

#### Organizational Responsibility

Every Asset SHALL identify the organization responsible for the represented State.

Organizational responsibility is independent of authorship, implementation, or ownership.

#### Stable Evolution

Assets evolve through immutable Versions.

Each Version represents the responsible State of a Subject at a particular point in time.

Previously published Versions remain valid historical representations of earlier States.

#### Multiple Representations

The same Asset MAY be represented by multiple Representations.

Different Representations MAY coexist for the same Asset Version.

Representations SHALL NOT define the identity of an Asset.

#### Interoperability

The model SHALL provide stable semantics that enable independent implementations to exchange, interpret, and manage Assets without requiring identical internal architectures.

## 3. Conceptual Model

The General Asset Model is constructed from a small number of fundamental concepts.

Each concept introduces one additional architectural abstraction.

The concepts are intentionally arranged in a logical sequence in which every concept depends only on concepts introduced earlier in this specification.

This approach avoids circular definitions and provides a stable conceptual foundation for specialized Asset Reference Models.

The conceptual progression is illustrated below.

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/3f6bc9be-86b3-4fa4-b5ce-01416788ee08/pictures/c9c5ae02-86f1-4586-bca2-376a27bcb2e6/content_img.png)

 

 

 

 

 

 

 

 

The conceptual sequence defined above is normative.

Specialized Asset Reference Models SHALL preserve the semantics of these concepts.

Specialized Asset Reference Models MAY introduce additional concepts, provided they do not alter the meaning of the concepts defined by this specification.

## 4. Core Concepts

The following sections define the architectural semantics of the core concepts introduced by the General Asset Model.

The concepts are presented in the normative sequence defined in Chapter 3.

Normative requirements governing their use are defined in Chapter 5.

### 4.1 Subject

A Subject is the entity being described.

A Subject may represent any identifiable object, concept, process, service, organization, product, software system, regulation, design, knowledge domain or any other matter of interest.

The General Asset Model intentionally places no restrictions on the nature of a Subject.

A Subject exists independently of any Asset.

Multiple Assets may describe the same Subject from different perspectives or by different responsible organizations.

#### Examples

- a software product
- a business process
- a design
- a regulation
- an engineering specification
- a body of knowledge

### 4.2 State

A State is a documented description of a Subject at a particular point in time.

A State captures those characteristics of the Subject that are considered relevant within a given context.

The General Asset Model does not distinguish between complete and partial descriptions.

A State may represent the entire Subject or only those aspects required for a specific purpose.

A State is purely descriptive.

It does not by itself express responsibility, applicability or publication.

### 4.3 Responsibility

Responsibility identifies the organization that accepts accountability for a documented State.

Responsibility expresses who stands behind the represented State.

It allows consumers to determine which organization published and maintains the described State.

Responsibility is independent of

- authorship,
- ownership,
- intellectual property,
- legal rights,
- or correctness.

Different organizations may independently accept responsibility for different States describing the same Subject.

### 4.4 Scope

A Scope defines the intended applicability of a documented State.

The Scope establishes the boundaries within which the represented State is intended to be interpreted.

A Scope may restrict applicability according to organizational, technical, legal, geographical, temporal or any other explicitly defined criteria.

The meaning of a State outside its declared Scope is undefined.

### 4.5 Asset

An Asset is the architectural entity that combines

- a Subject,
- a documented State,
- organizational Responsibility,
- and a defined Scope

into a managed architectural entity.

An Asset provides the unit through which documented knowledge, designs, software, processes or other Subjects can evolve in a controlled and traceable manner.

An Asset exists independently of any technical realization. It is an architectural concept rather than a physical artifact.

### 4.6 Version

A Version identifies one immutable revision of an Asset.

Each Version represents one immutable State of an Asset at a specific stage of its evolution.

Versions provide the basis for controlled change while preserving the traceability of previously published States.

### 4.7 Representation

A Representation is a concrete realization of an Asset Version.

Representations provide the means by which an Asset is stored, exchanged, processed or presented.

Representations are intended for publication, exchange, processing or presentation.

Examples include documents, packages, databases, structured data, diagrams, source code or other digital and physical forms.

Different Representations may exist simultaneously for the same Asset Version.

Representations do not alter the identity or semantics of the represented Asset.

### 4.8 Publication

Publication is the act of making a Representation of an Asset Version available for use by other parties.

Publication establishes a reference point from which a Version may be identified, exchanged and processed.

The mechanisms by which publication is performed are outside the scope of this specification.

## 5. Architectural Principles

The General Asset Model is governed by the following architectural principles.

All conforming implementations and all specialized Asset Reference Models SHALL preserve these principles.

### 5.1 Subject Principle

A Subject SHALL exist independently of any Asset.

Assets describe Subjects.

They do not define or create them.

### 5.2 Responsibility Principle

Every Asset SHALL identify exactly one responsible organization.

Responsibility SHALL be associated with the represented State rather than with its technical Representation.

### 5.3 Scope Principle

Every Asset SHALL define exactly one Scope.

Consumers SHALL interpret an Asset only within its declared Scope.

### 5.4 Version Principle

Every Asset SHALL evolve through immutable Versions.

Once published, a Version SHALL NOT be modified.

Changes SHALL result in a new Version.

### 5.5 Identity Principle

The identity of an Asset SHALL be independent of its Representations.

Replacing or adding Representations SHALL NOT change the identity of the Asset.

### 5.6 Representation Principle

An Asset Version MAY have one or more Representations.

All Representations of the same Version SHALL preserve identical semantics.

### 5.7 Relationship Principle

Relationships between Assets SHALL be represented explicitly.

Relationships SHALL NOT be inferred solely from Representations, file structures, naming conventions, or implementation-specific mechanisms.

### 5.8 Evolution Principle

The evolution of an Asset SHALL be represented as an ordered sequence of Versions.

Historical Versions SHOULD remain traceable.

### 5.9 Technology Principle

The concepts defined by this specification SHALL remain independent of programming languages, storage systems, exchange formats and communication protocols.

### 5.10 Specialization Principle

Specialized Asset Reference Models MAY introduce additional concepts.

They SHALL NOT change the meaning of the concepts defined by the General Asset Model.

## 6. Asset Lifecycle

The General Asset Model describes Assets as entities that evolve over time.

An Asset evolves as new information becomes available, decisions change, errors are corrected, or the represented Subject itself evolves.

The lifecycle defines the conceptual stages through which an Asset progresses.

The lifecycle describes the evolution of the Asset itself. It does not prescribe organizational processes or implementation workflows.

Specialized Asset Reference Models MAY refine the lifecycle by introducing additional stages, provided they preserve the lifecycle semantics defined by this specification.

### 6.1 Lifecycle Overview

An Asset typically progresses through the following lifecycle stages.

![](/uploads/dictionaries/64ca6f7b-5e26-4214-94f1-0920c7e4c8e9/3f6bc9be-86b3-4fa4-b5ce-01416788ee08/pictures/766b25ff-c14a-4631-9e9d-2f11bc46dae0/content_img.png)

The lifecycle defined by this specification is intentionally minimal.

Specialized Asset Reference Models MAY refine the lifecycle by introducing additional stages, provided they preserve the semantics of the lifecycle defined by this specification.

### 6.2 Created

The Created stage marks the initial establishment of an Asset.

During this stage, the Subject, documented State, Responsibility, and Scope have been defined sufficiently to establish the Asset.

The Asset exists as a managed architectural entity but has not yet been published.

The Created stage does not imply that the Asset is available to external consumers.

### 6.3 Published

The Published stage begins when a Representation of an Asset Version is made available to its intended consumers.

Publication establishes the published Version as an immutable reference.

After publication, the represented State SHALL NOT be modified.

Any subsequent change SHALL result in a new Asset Version.

### 6.4 Superseded

An Asset Version becomes Superseded when a newer Version replaces it as the preferred published Version of the same Asset.

Superseded Versions remain valid parts of the documented history of the Asset.

Supersession does not invalidate earlier Versions.

Consumers MAY continue to reference superseded Versions where appropriate.

### 6.5 Archived

The Archived stage indicates that an Asset Version is no longer expected to evolve or be actively maintained.

Archiving preserves the historical record of the published Version.

Archived Versions remain identifiable and MAY continue to be referenced.

Archiving does not imply deletion.

### 6.6 Lifecycle Principles

The lifecycle of an Asset Version SHALL satisfy the following principles.

#### Immutable Publication

A published Version SHALL remain immutable throughout its lifetime.

#### Traceable Evolution

The evolution of an Asset SHOULD remain traceable through its sequence of Versions.

#### Historical Preservation

Previous Versions SHOULD remain available whenever historical traceability is required.

#### Independent Lifecycle

The lifecycle of an Asset Version SHALL be independent of the lifecycle of any particular Representation.

Representations MAY be regenerated, transformed or migrated without changing the lifecycle state of the corresponding Asset Version.

#### Organizational Control

Transitions between lifecycle stages are determined by the responsible organization.

This specification intentionally does not prescribe organizational processes, governance models or publication procedures.

### 6.7 Relationship Between Lifecycle and Versioning

The lifecycle defined by this specification applies to individual Asset Versions rather than to the abstract Asset itself.

An Asset evolves through an ordered sequence of immutable Versions.

Each Version progresses independently through its own lifecycle until it becomes Superseded or Archived.

This distinction ensures that historical Versions remain valid and traceable while allowing the Asset itself to evolve continuously.

## 7. Asset Relationships

Assets rarely exist in isolation.

They typically form networks of related Assets that together describe a broader domain.

The General Asset Model does not prescribe a fixed relationship model. Instead, it defines the principles governing relationships between Assets.

Specialized Asset Reference Models MAY define additional relationship types appropriate to their respective domains.

### 7.1 General Principles

Relationships express semantic connections between Assets.

Relationships are independent architectural elements and are not part of the identity of the connected Assets.

Relationships SHALL be represented explicitly.

Their existence SHALL NOT be inferred solely from Representations, file structures, naming conventions or implementation-specific mechanisms.

Each relationship SHALL have a clearly defined semantic meaning.

### 7.2 Relationship Characteristics

Relationships MAY be

- directional,
- bidirectional,
- hierarchical,
- associative, or
- domain-specific.

The semantics of a relationship are determined exclusively by its defined relationship type.

### 7.3 Identity of Relationships

Relationships connect Assets.

They neither create nor modify the identity of the connected Assets.

Changing or removing a relationship SHALL NOT alter the identity of either Asset.

### 7.4 Relationship Scope

Relationships MAY reference

- Assets,
- specific Asset Versions, or
- both,

depending on the semantics defined by the specialized Asset Reference Model.

The intended scope of every relationship SHALL be explicitly defined.

### 7.5 Common Relationship Types

The following relationship types provide a minimal common foundation for specialized Asset Reference Models.

| Relationship | Meaning |
| --- | --- |
| references | indicates an informational reference to another Asset |
| depends_on | indicates that one Asset depends on another Asset |
| specializes | indicates that one Asset specializes another Asset |

Additional relationship types MAY be introduced by specialized specifications.

### 7.6 Relationship Integrity

Implementations SHOULD ensure that referenced Assets can be uniquely identified.

The mechanisms used to resolve relationships are outside the scope of this specification.

Broken or unresolved relationships SHALL NOT invalidate the identity of an Asset.

Implementations SHOULD report unresolved relationships to consumers.

## 8. Conformance

This chapter defines the minimum requirements for claiming conformance with the General Asset Model.

The purpose of conformance is to ensure that independent implementations and specialized Asset Reference Models preserve the architectural semantics defined by this specification.

### 8.1 Conforming Implementations

An implementation claiming conformance SHALL

- implement the core concepts defined in Chapter 4,
- preserve the architectural principles defined in Chapter 5,
- preserve the lifecycle semantics defined in Chapter 6, and
- preserve the relationship semantics defined in Chapter 7.

Implementations MAY introduce additional functionality, provided that it does not alter the semantics defined by this specification.

### 8.2 Specialized Asset Reference Models

Specialized Asset Reference Models SHALL

- preserve all concepts defined by the General Asset Model,
- preserve the semantics of those concepts, and
- remain compatible with the architectural principles defined by this specification.

They MAY introduce

- additional concepts,
- additional relationship types,
- additional lifecycle stages, and
- domain-specific constraints.

Such extensions SHALL NOT redefine or contradict the concepts defined by the General Asset Model.

### 8.3 Technology Independence

Conformance SHALL be independent of

- programming languages,
- storage technologies,
- serialization formats,
- exchange protocols,
- cryptographic mechanisms,
- implementation frameworks.

Different implementations MAY use different technologies while remaining fully conformant.

### 8.4 Representation Independence

Conformance applies to the architectural model rather than to any particular Representation.

The same conforming Asset MAY therefore be represented by multiple independent Representations.

Representations SHALL preserve the semantics of the represented Asset.

### 8.5 Forward Compatibility

Implementations SHOULD preserve interoperability when processing extensions that are not understood, provided that doing so does not alter the interpretation of the architectural concepts defined by this specification.

This principle supports the future evolution of specialized Asset Reference Models while preserving interoperability.

### 8.6 Non-Conformance

An implementation SHALL NOT claim conformance with this specification if it

- changes the meaning of the concepts defined in Chapter 4,
- violates the architectural principles defined in Chapter 5,
- alters the lifecycle semantics defined in Chapter 6, or
- redefines the relationship semantics defined in Chapter 7.

 
