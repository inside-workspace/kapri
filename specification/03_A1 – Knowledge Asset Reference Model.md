# A1 – Knowledge Asset Reference Model

Version: 0.9.0  
Status: Release Candidate  
Type: Normative Model Specification  
Author: Sabine Wax

Copyright © 2026 inside workspace GmbH  
This work is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) License.

## 1. Introduction

### 1.1 Purpose

This document defines the Knowledge Asset Reference Model.

The Knowledge Asset Reference Model specializes the General Asset Model for the domain of knowledge. It establishes the concepts required to describe responsible, versioned organizational knowledge.

This specification is normative.

### 1.2 Scope

This specification defines

- the concept of Knowledge State as a specialization of State,
- the characteristics of Knowledge Assets,
- the architectural specialization of the General Asset Model for knowledge.

This specification does not define

- package structures,
- metadata schemas,
- publication mechanisms,
- exchange formats,
- serialization,
- cryptographic mechanisms,
- implementation technologies.

These subjects are defined by other specifications of the KAPRI Specification Suite.

### 1.3 Relationship to A0

This specification specializes the General Asset Model.

All concepts defined by A0 remain valid.

Where this specification introduces additional concepts, they extend but do not redefine the semantics established by the General Asset Model.

## 2. Introduction

Knowledge enables people and organizations to understand situations, make decisions and perform actions.

Knowledge represents an explicit organizational understanding of a defined Subject.

Knowledge evolves continuously.

New evidence becomes available.

Experience accumulates.

Assumptions are refined.

Consequently, knowledge cannot be regarded as static.

Instead, organizations continuously develop successive knowledge States representing their current understanding of a Subject.

The purpose of a Knowledge Asset is to make such knowledge explicit, versioned and attributable to the organization accepting responsibility for it.

A Knowledge Asset therefore represents organizational knowledge rather than individual opinion.

The General Asset Model defines the architectural concepts required for all Assets.

This specification specializes those concepts for knowledge.

### 2.1 Design Objectives

The Knowledge Asset Reference Model specializes the General Asset Model while preserving its architectural semantics.

The Knowledge Asset Reference Model has been designed according to the following objectives.

#### Organizational Responsibility

Knowledge Assets represent knowledge for which an organization accepts responsibility.

#### Explicit Evolution

Knowledge evolves through successive Versions reflecting changes in organizational understanding.

#### Interoperability

Knowledge Assets are intended to be exchanged and used consistently across organizational boundaries.

#### Traceability

Consumers shall be able to determine

- who published the knowledge,
- which Version they use,
- and within which Scope it applies.

#### Technology Independence

Knowledge remains independent of the technologies used to represent or exchange it.

## 3. Organizational Knowledge

Organizational knowledge represents an explicit organizational understanding of a defined Subject.

Organizational knowledge is more than a collection of information. It represents information that has been interpreted, structured and accepted within an organizational context.

Organizational knowledge exists independently of its Representation.

Within the Knowledge Asset Reference Model, documented Organizational Understanding is represented as a Knowledge State.

Different organizations may independently develop Knowledge Assets concerning the same Subject.

Each Knowledge Asset reflects the Organizational Understanding for which its responsible organization accepts Responsibility. Knowledge Assets therefore enable multiple independent organizational perspectives on the same Subject.

## 4. Core Concepts

This chapter specializes the General Asset Model for the domain of knowledge.

All concepts defined by the General Asset Model remain valid.

The concepts introduced in this chapter describe the characteristics that distinguish Knowledge Assets from other specialized Asset types.

### 4.1 Knowledge

Knowledge is the explicit organizational understanding of a defined Subject.

Knowledge is created by interpreting, structuring and validating information within a specific organizational context.

Knowledge enables organizations to understand situations, make decisions and perform actions.

Knowledge is independent of the media used to represent it.

Documents, databases, diagrams or software systems may contain Representations of knowledge, but they do not constitute the knowledge itself.

Knowledge evolves continuously as organizational understanding changes.

### 4.2 Knowledge State

A Knowledge State is the State of a Knowledge Asset.

It represents the documented organizational understanding of a defined Subject at a particular point in time.

A Knowledge State is descriptive. It does not by itself express Responsibility, Scope, Version or Publication.

Every Version of a Knowledge Asset represents exactly one Knowledge State.

Knowledge States evolve as organizational understanding changes through new evidence, experience, revised assumptions, corrected errors or changing organizational objectives.

A Knowledge State does not imply correctness or universal truth.

### 4.3 Organizational Understanding

Organizational Understanding is the shared interpretation of a Subject accepted by an organization.

It is the result of organizational learning rather than individual opinion.

Organizational Understanding enables consistent decisions and actions within the responsible organization.

Different organizations may legitimately develop different understandings of the same Subject.

The General Asset Model therefore permits multiple independent Knowledge Assets concerning the same Subject.

### 4.4 Knowledge Source

A Knowledge Source provides evidence supporting a Knowledge State.

Knowledge Sources may include

- scientific publications,
- standards,
- regulations,
- project documentation,
- operational data,
- expert knowledge,
- measurements,
- observations,
- or other verifiable information.

Knowledge Sources contribute to the development of a Knowledge State.

Knowledge Sources may themselves be represented as Knowledge Assets.

They are not themselves Knowledge Assets unless they independently satisfy the requirements defined by the General Asset Model and this specification.

### 4.5 Knowledge Asset

A Knowledge Asset is an Asset whose State is a Knowledge State.

A Knowledge Asset combines

- a defined Subject,
- a documented Knowledge State,
- organizational Responsibility,
- and a defined Scope

into a managed architectural entity.

A Knowledge Asset enables organizations to manage and publish explicit organizational understanding in a controlled, traceable and versioned manner.

Knowledge Assets exist independently of their technical Representations.

A document, Package or database therefore represents a Knowledge Asset Version but is not the Knowledge Asset itself.

## 5. Characteristics of Knowledge Assets

Knowledge Assets differ from traditional documents because they represent organizational understanding rather than isolated information.

The following characteristics distinguish Knowledge Assets from other specialized Asset types.

### 5.1 Organizational Responsibility

Every Knowledge Asset represents knowledge for which exactly one responsible organization accepts accountability.

Responsibility applies to the represented Knowledge State.

It does not imply ownership of the underlying information or exclusive authority over the Subject.

Multiple organizations may independently publish Knowledge Assets describing the same Subject.

### 5.2 Explicit Knowledge

Knowledge represented by a Knowledge Asset SHALL be explicit.

Tacit knowledge possessed only by individuals is outside the scope of this specification until it has been documented as organizational understanding.

### 5.3 Traceable Evolution

Knowledge evolves continuously.

Every modification of organizational understanding SHALL result in a new Version of the Knowledge Asset.

Previously published Versions remain valid historical representations of earlier Knowledge States.

### 5.4 Contextual Validity

Knowledge is always interpreted within a defined Scope.

Consumers SHALL evaluate a Knowledge Asset only within its declared Scope.

Knowledge represented outside that Scope may require a different Knowledge Asset.

### 5.5 Evidence-Based Development

Knowledge Assets SHOULD be supported by appropriate Knowledge Sources.

The nature and quality of supporting evidence depend on the intended Scope and purpose of the Knowledge Asset.

This specification intentionally does not prescribe evaluation methods.

### 5.6 Independent Representations

A Knowledge Asset MAY be represented by multiple technical Representations.

All Representations SHALL preserve the same semantic meaning.

Changing a Representation SHALL NOT change the identity or meaning of the Knowledge Asset.

### 5.7 Independent Perspectives

Different organizations MAY publish different Knowledge Assets concerning the same Subject.

The coexistence of different organizational understandings is an inherent characteristic of knowledge.

Consumers determine which Knowledge Assets are appropriate for their own purposes.

## 6. Knowledge Evolution

Knowledge is not static.

Organizations continuously refine their understanding of the Subjects relevant to their activities.

The evolution of knowledge is therefore a fundamental characteristic of every Knowledge Asset.

Knowledge Assets enable organizations to document this evolution in a controlled, traceable and versioned manner.

The purpose of versioning is not merely to record changes but to preserve the history of organizational understanding.

### 6.1 Evolution of Organizational Understanding

Organizational understanding evolves whenever the responsible organization changes its accepted understanding of a Subject.

Such changes may result from

- new evidence,
- operational experience,
- scientific discoveries,
- revised regulations,
- technological developments,
- organizational decisions,
- corrected assumptions,
- or changing business objectives.

The General Asset Model intentionally does not distinguish between these causes.

Any change to the accepted organizational understanding constitutes a new Knowledge State.

### 6.2 Knowledge Versions

Every Knowledge State accepted for publication constitutes a new Version of the Knowledge Asset.

Each Version represents the organizational understanding at a specific point in time.

Versions preserve the complete evolution of organizational knowledge.

Historical Versions remain valid descriptions of earlier organizational understanding.

A newer Version does not invalidate earlier Versions.

It supersedes them as the current organizational understanding.

### 6.3 Continuity

Knowledge evolution is continuous.

Organizations continuously improve their understanding rather than replacing knowledge completely.

Successive Versions therefore represent the evolution of one Knowledge Asset rather than unrelated Assets.

The identity of the Knowledge Asset remains stable throughout its evolution.

### 6.4 Organizational Independence

Knowledge evolves independently within each organization.

Different organizations may publish different Versions describing the same Subject.

These Versions reflect independent organizational understanding.

This specification intentionally does not define a central authority responsible for determining the correctness of organizational understanding.

Consumers decide which organizational understanding is appropriate for their intended purpose.

### 6.5 Preservation of Knowledge History

Knowledge history forms an integral part of a Knowledge Asset.

Historical Versions provide transparency regarding

- previous organizational understanding,
- decisions,
- assumptions,
- and the evolution of knowledge over time.

The preservation of historical Versions supports traceability, reproducibility and organizational learning.

## 7. Knowledge Relationships

Knowledge Relationships specialize the Asset Relationships defined by the General Asset Model.

Knowledge does not exist in isolation.

Knowledge Assets form networks describing how organizational understanding is connected across different Subjects.

Knowledge Relationships express these semantic connections.

Unlike technical references between files or packages, Knowledge Relationships describe relationships between the represented knowledge itself.

### 7.1 General Principles

Knowledge Relationships are semantic relationships between Knowledge Assets.

Relationships describe how one organizational understanding relates to another.

Relationships are independent of technical Representations.

The same Knowledge Relationship may therefore exist regardless of how the involved Knowledge Assets are represented.

### 7.2 Knowledge Networks

Knowledge Assets naturally form interconnected knowledge networks.

Within such networks,

- concepts build upon other concepts,
- decisions depend on previously established knowledge,
- definitions reference related definitions,
- processes reuse organizational understanding,
- and design decisions build upon earlier knowledge.

Knowledge networks emerge through explicit semantic relationships between Knowledge Assets.

### 7.3 Relationship Types

The following relationship types commonly occur between Knowledge Assets.

| Relationship | Meaning |
| --- | --- |
| references | cites another Knowledge Asset as supporting information |
| depends_on | requires another Knowledge Asset for interpretation |
| specializes | provides a more specific organizational understanding |
| generalizes | provides a broader organizational understanding |
| supersedes | replaces an earlier organizational understanding |
| contains | groups multiple Knowledge Assets within a larger organizational context |

Specialized Knowledge Models MAY introduce additional relationship types.

### 7.4 Semantic Integrity

Knowledge Relationships SHALL preserve semantic consistency.

Relationships SHALL describe organizational understanding rather than implementation structures.

Consumers SHALL be able to interpret relationships without knowledge of the technical Representations.

### 7.5 Independent Evolution

Related Knowledge Assets evolve independently.

A new Version of one Knowledge Asset does not require new Versions of all related Knowledge Assets.

Organizations determine independently when changes in one Knowledge Asset require revisions of related Knowledge Assets.

This principle enables scalable evolution of large knowledge networks.

### 7.6 Knowledge Graphs

The relationships defined by this specification enable Knowledge Assets to form semantic knowledge graphs.

A Knowledge Graph represents interconnected organizational understanding rather than merely linked documents.

The structure of such graphs is determined by the semantic relationships between Knowledge Assets and not by their technical Representations.

## 8. Conformance

This chapter defines the minimum requirements for claiming conformance with the Knowledge Asset Reference Model.

The purpose of conformance is to ensure that independent implementations preserve the semantics of Knowledge Assets while remaining interoperable across organizations.

This specification specializes the General Asset Model.

Conformance with this specification therefore requires conformance with A0 – General Asset Model.

### 8.1 General Conformance

An implementation claiming conformance with this specification SHALL

- conform to the General Asset Model defined in A0,
- implement the concepts defined in Chapter 4,
- preserve the characteristics defined in Chapter 5,
- support the knowledge evolution semantics defined in Chapter 6,
- preserve the relationship semantics defined in Chapter 7.

Implementations MAY introduce additional functionality provided that such extensions do not change the semantics defined by this specification.

### 8.2 Knowledge Assets

A conforming Knowledge Asset SHALL

- have Knowledge as its Subject,
- represent an explicit organizational understanding,
- identify exactly one responsible organization,
- define a Scope,
- evolve through immutable Versions,
- remain independent of its technical Representations.

### 8.3 Organizational Independence

Conforming implementations SHALL support the coexistence of Knowledge Assets published by different organizations.

This specification intentionally permits different organizations to publish different organizational understandings of the same Subject.

Conformance SHALL NOT require agreement between organizations.

### 8.4 Representation Independence

Knowledge Assets are architectural entities.

Their Representations are implementation artifacts.

A conforming implementation SHALL preserve the semantic identity of a Knowledge Asset independently of the technologies used to represent, store or exchange it.

### 8.5 Extensibility

Specialized Knowledge Models MAY introduce additional concepts, constraints or relationship types provided that such extensions remain compatible with this specification.

Such extensions SHALL

- remain compatible with the General Asset Model,
- preserve the semantics of Knowledge defined by this specification,
- and SHALL NOT redefine the meaning of the concepts introduced in Chapters 4 to 7.

### 8.6 Non-Conformance

An implementation SHALL NOT claim conformance with this specification if it

- changes the definition of Knowledge established by this specification,
- represents implicit individual knowledge as organizational knowledge without making it explicit,
- changes the semantics of Knowledge Assets defined by this specification,
- modifies published Versions,
- or changes the identity of a Knowledge Asset through its technical Representation.

