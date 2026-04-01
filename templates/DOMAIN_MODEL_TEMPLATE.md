# Domain Model: [Project/Feature Name]

**Source RFC:** RFC-[NUMBER]
**Last Updated:** YYYY-MM-DD

---

## 1. Bounded Contexts

### Context Map

<!-- Diagram showing all bounded contexts and their relationships.
     Use: Upstream/Downstream, Shared Kernel, Anti-Corruption Layer,
     Conformist, Open Host Service, Published Language. -->

```
[Context A] --downstream/conformist--> [Context B]
[Context A] --anti-corruption-layer--> [Context C (external)]
```

### 1.1 [Bounded Context Name]

**Responsibility:** [One sentence describing what this context owns]
**Module/Package:** `src/modules/[context-name]/`

**Upstream dependencies:** [What contexts does it consume from?]
**Downstream consumers:** [What contexts consume from it?]
**Integration pattern:** [REST, events, shared kernel, etc.]

<!-- Repeat for each bounded context -->

---

## 2. Ubiquitous Language

<!-- Every term used in the domain. These become class names, method names,
     variable names. NO SYNONYMS. One term per concept. -->

| Term               | Definition                                    | Used In Context     |
| ------------------ | --------------------------------------------- | ------------------- |
| [Term]             | [Precise definition]                          | [Context Name]      |

---

## 3. Aggregates

### 3.1 [Aggregate Name]

**Aggregate Root:** `[RootEntityName]`
**Bounded Context:** [Context Name]

#### Entities

| Entity Name        | Identity (ID type) | Description                          |
| ------------------ | ------------------ | ------------------------------------ |
| [RootEntity]       | UUID               | The aggregate root. Entry point.     |
| [ChildEntity]      | UUID               | Belongs to root, cannot exist alone. |

#### Value Objects

| Value Object       | Properties                     | Validation Rules                   |
| ------------------ | ------------------------------ | ---------------------------------- |
| [ValueObjectName]  | `field1: Type, field2: Type`   | field1 > 0, field2 not empty       |

#### Invariants

<!-- Business rules that must ALWAYS hold true for this aggregate.
     These become assertions in domain tests. -->

1. **INV-001:** [Invariant description]. Example: "Order total must equal sum of line item subtotals."
2. **INV-002:** [Invariant description].

#### Domain Events

| Event              | Trigger                        | Payload                            |
| ------------------ | ------------------------------ | ---------------------------------- |
| [EventName]        | When [condition]               | `{ field1, field2 }`               |

#### Repository Interface (Port)

```
interface [AggregateNameRepository]:
    save(aggregate: [AggregateName]): void
    findById(id: ID): [AggregateName] | null
    [other query methods as needed]
```

<!-- Repeat section 3.x for each aggregate -->

---

## 4. Domain Services

<!-- Operations that span multiple aggregates or don't belong to any single entity. -->

### 4.1 [ServiceName]

**Purpose:** [What does this service do?]
**Input:** [Parameters]
**Output:** [Return value]
**Aggregates involved:** [List]
**Business rules applied:** [Reference invariant IDs]

```
interface [ServiceName]:
    execute(input: InputType): OutputType
```

---

## 5. Integration Events (Cross-Context)

<!-- Events that cross bounded context boundaries. These are different from
     domain events — they are the public contract between contexts. -->

| Event                 | Publisher Context | Consumer Context(s) | Payload (public contract)    |
| --------------------- | ----------------- | ------------------- | ---------------------------- |
| [IntegrationEvent]    | [Context A]       | [Context B, C]      | `{ field1, field2 }`         |

---

## 6. Anti-Corruption Layers

<!-- For each external system integration, define the ACL that translates
     between the external model and your domain model. -->

### 6.1 [External System Name] ACL

**External model:** [Describe how the external system represents data]
**Our domain model:** [How we represent the same concept]
**Translation:** [Mapping rules]

```
interface [ExternalSystemAdapter]:
    translateToDomain(externalData: ExternalType): DomainType
    translateToExternal(domainData: DomainType): ExternalType
```

---

## 7. Module Dependency Diagram

<!-- Show which modules depend on which. Verify the dependency rule:
     domain has zero outward dependencies. -->

```
infrastructure → application → domain
      ↓                ↓
  [frameworks]    [domain ports only]
```
