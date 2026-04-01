# DDD Reference Guide

## Purpose

This guide helps you build a domain model from an RFC specification. The goal is to
produce a `DOMAIN_MODEL.md` that captures all business logic in a framework-agnostic,
infrastructure-free model.

---

## Core Concepts

### Bounded Context

A boundary within which a particular domain model is defined and applicable. Different
contexts can have different models for the same real-world concept (e.g., "User" in
an Auth context vs. "Customer" in a Billing context). Each context owns its data and
logic — no shared databases.

**How to identify contexts from an RFC:**
- Look at the RFC's system overview — each major component is often a context
- Look for terms that have different meanings in different sections — that signals a boundary
- Look for data ownership — who is the source of truth for each entity?

### Aggregate

A cluster of domain objects treated as a single unit for data changes. The aggregate root
is the only entry point — external code never modifies child entities directly.

**Design rules:**
- Keep aggregates small. Prefer small aggregates over large ones.
- Reference other aggregates by ID only, never by direct object reference.
- One transaction = one aggregate. Cross-aggregate consistency is eventual (via events).
- The aggregate root enforces all invariants before persisting.

**How to identify aggregates from an RFC:**
- Look at the data model — entities that must be consistent together form an aggregate
- Look at the business rules — invariants that span multiple entities suggest they belong together
- Look at the transactional boundaries — what must be atomically consistent?

### Entity

An object with a unique identity that persists across state changes. Two entities with
the same attributes but different IDs are different entities.

**When to use:** The object has a lifecycle, is tracked over time, or needs to be
distinguished from other objects with similar attributes.

### Value Object

An immutable object defined by its attributes, not by identity. Two value objects with
the same attributes are equal. No ID needed.

**When to use:** The object describes a characteristic, quantity, or measurement.
Examples: Money(amount, currency), Address(street, city, zip), EmailAddress(value).

**Design rules:**
- Always immutable — create new instances instead of modifying
- Validate in constructor — a value object is always valid or doesn't exist
- Include equality by value (not reference)

### Domain Event

A record of something that happened in the domain. Past tense naming: `OrderPlaced`,
`PaymentReceived`, `UserSuspended`. Events are immutable facts.

**When to use:**
- Something happened that other parts of the system need to react to
- You need an audit trail of state changes
- Cross-aggregate or cross-context communication

**Design rules:**
- Events are immutable — once emitted, they never change
- Events carry enough data for consumers to act without calling back to the producer
- Name events in past tense (they describe what already happened)

### Domain Service

An operation that doesn't naturally belong to any entity or value object. Often involves
coordinating multiple aggregates or encapsulating a complex business rule.

**When to use:**
- The operation involves multiple aggregates
- The operation is a stateless business calculation
- Putting the logic on an entity would violate SRP

**When NOT to use:**
- If it can live on an entity or aggregate root, put it there
- If it's orchestration/coordination, it's a use case (application layer), not a domain service

### Repository (Port)

An interface defined in the domain layer that abstracts persistence. The domain declares
what it needs; infrastructure provides the implementation.

**Design rules:**
- Define in the domain layer as an interface/protocol/trait
- Method names should use domain language: `findActiveOrders()`, not `selectWhereStatusActive()`
- Return domain objects, not database rows or DTOs
- One repository per aggregate root

---

## Workflow: RFC → Domain Model

1. **Extract the glossary** from the RFC. These terms become your ubiquitous language.

2. **Identify bounded contexts** from the system overview and data ownership patterns.

3. **For each context, identify aggregates:**
   - Group entities from the RFC data model by transactional boundary
   - Identify which entity is the root (the one external code interacts with)
   - Extract child entities and value objects

4. **Define invariants** from the RFC's business rules section. Map each rule to an
   aggregate. If a rule spans aggregates, consider a domain service or reconsider
   your aggregate boundaries.

5. **Define domain events** from the RFC's state machines and side effects. Each
   state transition or significant action should emit an event.

6. **Define repository interfaces** — one per aggregate root, with methods derived
   from the use cases in the RFC.

7. **Draw the context map** showing relationships between contexts.

8. **Validate:** Read through the RFC's edge cases. Can your domain model handle
   each one? If not, refine.

---

## Common Pitfalls

**Anemic Domain Model:** Entities that are just data holders with getters/setters, while
all logic lives in services. Fix: move business logic into entities and aggregates.

**God Aggregate:** One massive aggregate that contains everything. Fix: split by
transactional boundary. Ask: "Does updating X always require updating Y atomically?"
If no, they're separate aggregates.

**Infrastructure in Domain:** Domain entities importing database clients, HTTP libraries,
or framework types. Fix: the domain layer has zero external dependencies. Use ports.

**Direct Aggregate References:** Aggregate A holding a direct reference to Aggregate B.
Fix: reference by ID. Load B through its own repository when needed.

**Ignoring Bounded Contexts:** Using the same model everywhere. Fix: let each context
have its own model. Use an anti-corruption layer to translate between them.
