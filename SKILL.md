---
name: spec-driven-dev
description: >
  Structured software development methodology that front-loads clarity before code generation
  to minimize wasted AI tokens and maximize first-shot accuracy. Enforces a strict pipeline:
  RFC Spec → Domain Model → Test Contracts → Implementation → Refactor. Use this skill whenever
  the user wants to build a new feature, service, module, or application — especially when they
  mention specs, architecture, DDD, TDD, clean architecture, SOLID, or express frustration with
  AI-generated code quality. Also trigger when the user says things like "let's plan this properly",
  "I want to spec this out first", "stop guessing and let me define it", "design before code",
  "help me architect this", or starts a new project/feature of non-trivial complexity. Even if the
  user jumps straight to "build X", suggest this process when the scope is large enough that
  ad-hoc prompting would waste tokens. Do NOT trigger for quick one-off scripts, simple bug fixes,
  or tasks where the user explicitly says they want to skip planning.
---

# Spec-Driven Development Methodology

## Philosophy

Every token spent on ambiguous prompts is a token wasted. This methodology exists to ensure
that by the time AI writes a single line of code, the spec is so precise that the first
generation is usable. The pipeline is sequential and gated — each phase produces a concrete
artifact that becomes input context for the next phase.

**The Pipeline:**

```
Phase 0: Intent Capture
Phase 1: RFC Specification
Phase 2: Domain Model (DDD)
Phase 3: Test Contracts (TDD)
Phase 4: Implementation (Clean Architecture + SOLID)
Phase 5: Review & Refactor
```

Each phase has a **gate** — a checklist of artifacts that must exist before proceeding. Never
skip a gate. If the user wants to jump ahead, surface what's missing and help them fill gaps
quickly rather than skipping.

---

## Phase 0: Intent Capture

**Goal:** Understand what the user actually wants before writing anything formal.

Ask these questions (adapt to context — some may already be answered):

1. **What problem does this solve?** (one sentence)
2. **Who/what are the actors?** (users, systems, cron jobs, external APIs)
3. **What are the key operations?** (verbs: create, process, notify, sync)
4. **What are the boundaries?** (what is explicitly OUT of scope)
5. **What does success look like?** (measurable outcome)
6. **Are there existing systems this must integrate with?**
7. **What's the target stack?** (language, framework, infra — or "undecided")

Capture answers in a brief `INTENT.md` or use them directly as input to Phase 1.

**Gate 0:** Problem statement, actors, key operations, and scope boundaries are defined.

---

## Phase 1: RFC Specification

**Goal:** Produce a formal, self-contained specification document that eliminates ambiguity.

Read the RFC template at `templates/RFC_TEMPLATE.md` before writing the RFC. Every RFC
must follow that structure. Key principles:

- **Be exhaustive on interfaces.** Every function signature, API endpoint, message format,
  and data shape must be specified. If it crosses a boundary, it needs a contract.
- **Enumerate edge cases explicitly.** A section titled "Edge Cases & Error Handling" is
  mandatory. List every known edge case with its expected behavior.
- **Include non-functional requirements.** Performance targets, security constraints,
  observability requirements, deployment constraints.
- **Use concrete examples.** For every interface, include at least one request/response
  example or input/output example with realistic data.
- **Mark open questions.** Use `[OPEN]` tags for unresolved decisions. These must be
  resolved before the gate passes.

**Gate 1 Checklist:**
- [ ] RFC follows `templates/RFC_TEMPLATE.md` structure
- [ ] All `[OPEN]` questions are resolved
- [ ] Every external interface has a contract with examples
- [ ] Edge cases section has ≥5 entries (or justified fewer)
- [ ] Non-functional requirements are quantified where possible
- [ ] Glossary defines all domain terms
- [ ] User has reviewed and approved the RFC

---

## Phase 2: Domain Model (DDD)

**Goal:** Define the domain model with bounded contexts, aggregates, entities, value objects,
domain events, and repository interfaces — all derived from the RFC.

Read `references/DDD_GUIDE.md` for the full DDD workflow. Key steps:

1. **Identify Bounded Contexts** from the RFC's scope. Each bounded context maps to a
   module/package boundary. Draw context maps showing relationships (upstream/downstream,
   shared kernel, anti-corruption layer).

2. **Define the Ubiquitous Language.** Extract domain terms from the RFC glossary. These
   become class/type names. No synonyms — one term per concept, used everywhere.

3. **Model Aggregates.** For each aggregate:
   - Identify the aggregate root (the entry point for all mutations)
   - List entities within the aggregate
   - Define value objects (immutable, equality by value)
   - Specify invariants (business rules that must always hold)
   - Define domain events emitted by state transitions

4. **Define Repository Interfaces.** Repositories are ports — abstract interfaces that the
   domain declares and infrastructure implements. Define the contract, not the implementation.

5. **Define Domain Services.** Operations that don't belong to a single aggregate. These
   coordinate across aggregates or encapsulate domain logic that isn't entity-specific.

**Output format:** A `DOMAIN_MODEL.md` document structured per `templates/DOMAIN_MODEL_TEMPLATE.md`.

**Gate 2 Checklist:**
- [ ] Bounded contexts identified with context map
- [ ] Ubiquitous language documented (glossary updated)
- [ ] All aggregates defined with roots, entities, value objects, invariants
- [ ] Domain events listed with trigger conditions and payload shapes
- [ ] Repository interfaces defined as abstract ports
- [ ] Domain services identified (if any)
- [ ] No infrastructure concerns leak into domain definitions

---

## Phase 3: Test Contracts (TDD)

**Goal:** Define test cases BEFORE implementation. Tests are contracts that validate the spec
and domain model. When handed to AI for implementation, these tests constrain the solution space
and make validation immediate.

Read `references/TDD_GUIDE.md` for the full testing strategy. Key principles:

1. **Test the Domain First.** Unit tests for aggregates, value objects, and domain services.
   These tests exercise invariants and business rules with no infrastructure dependencies.

2. **Test Use Cases Second.** Integration-level tests for application services / use cases.
   Mock or stub repository ports. Verify orchestration logic and domain event emission.

3. **Test Adapters Last.** Only after domain and use case tests pass, write adapter tests
   for actual infrastructure (database queries, HTTP handlers, message consumers).

4. **Structure tests as Given-When-Then:**
   - **Given:** Set up the precondition state
   - **When:** Execute the operation under test
   - **Then:** Assert the postcondition (state change, event emitted, error raised)

5. **Write test signatures and assertions first, implementation stubs second.**
   The test file is the artifact. Include:
   - Test name (descriptive, reads like a sentence)
   - Arrange/Given section with concrete data
   - Act/When section calling the method/function under test
   - Assert/Then section with exact expected values

6. **Cover the edge cases from the RFC.** Every entry in the RFC's edge case section
   must have a corresponding test.

**Output format:** Test files organized by layer:
```
tests/
├── domain/          # Pure domain tests (aggregates, value objects, services)
├── application/     # Use case tests (mocked ports)
└── adapter/         # Infrastructure tests (real dependencies or test containers)
```

**Gate 3 Checklist:**
- [ ] Domain layer tests cover all aggregate invariants
- [ ] Domain layer tests cover all value object equality/validation rules
- [ ] Use case tests cover happy path + error paths for each use case
- [ ] Every RFC edge case has a corresponding test
- [ ] Tests are runnable (even if they fail — they should compile/parse)
- [ ] Test names read as behavior specifications
- [ ] No test depends on implementation details (test behavior, not structure)

---

## Phase 4: Implementation (Clean Architecture + SOLID)

**Goal:** Generate production code that makes all tests pass, organized in Clean Architecture
layers, following SOLID principles.

Read `references/CLEAN_ARCH_GUIDE.md` for the layer structure. Read `references/SOLID_GUIDE.md`
for the SOLID review checklist.

### Layer Structure

```
src/
├── domain/           # Enterprise business rules
│   ├── entities/     # Aggregates, entities, value objects
│   ├── events/       # Domain event definitions
│   ├── services/     # Domain services
│   └── ports/        # Repository interfaces, external service ports
├── application/      # Application business rules (use cases)
│   ├── usecases/     # One class/function per use case
│   ├── dtos/         # Input/output data transfer objects
│   └── services/     # Application services (orchestration)
├── infrastructure/   # Frameworks & drivers
│   ├── persistence/  # Repository implementations, ORM configs
│   ├── http/         # Controllers, routes, middleware
│   ├── messaging/    # Event bus, queue consumers/producers
│   └── config/       # DI container, environment config
└── shared/           # Cross-cutting (logging, errors, utils)
```

### Dependency Rule

Dependencies point inward ONLY:
- `infrastructure` → `application` → `domain`
- `domain` has ZERO external dependencies (no framework imports, no DB drivers)
- `application` depends only on `domain` ports (interfaces)
- `infrastructure` implements `domain` ports and wires everything together

### Implementation Sequence

1. **Domain layer first.** Implement entities, value objects, domain events, domain services.
   Run domain tests. All should pass.
2. **Application layer second.** Implement use cases that orchestrate domain objects.
   Run use case tests (with mocked ports). All should pass.
3. **Infrastructure layer last.** Implement repository adapters, HTTP handlers, messaging.
   Run adapter tests. All should pass.
4. **Composition root.** Wire DI container. Run full integration tests.

### SOLID Review (apply after each layer)

For each class/module, verify:
- **S** — Single Responsibility: Does it have exactly one reason to change?
- **O** — Open/Closed: Can it be extended without modification?
- **L** — Liskov Substitution: Can any implementation of an interface replace another?
- **I** — Interface Segregation: Are interfaces small and focused?
- **D** — Dependency Inversion: Does it depend on abstractions, not concretions?

If any check fails, refactor before moving to the next layer.

**Gate 4 Checklist:**
- [ ] All domain tests pass
- [ ] All use case tests pass
- [ ] All adapter tests pass
- [ ] Dependency rule is not violated (no inward imports of outer layers)
- [ ] SOLID review passes for every class/module
- [ ] No business logic exists in infrastructure layer
- [ ] DI container wires all ports to adapters

---

## Phase 5: Review & Refactor

**Goal:** Final quality pass before declaring the work complete.

1. **Code Review Checklist:**
   - No dead code or commented-out blocks
   - Naming matches ubiquitous language from domain model
   - Error handling is explicit (no swallowed exceptions)
   - Logging/observability is in place per NFRs
   - No hardcoded values that should be config

2. **Architecture Review:**
   - Run dependency analysis — confirm no layer violations
   - Verify all ports have at least one adapter
   - Confirm domain events are consumed somewhere (or documented as future work)

3. **Documentation:**
   - README updated with setup/run instructions
   - ADRs written for any decisions made during implementation that deviated from RFC
   - API docs generated (if applicable)

4. **Token Audit (self-assessment):**
   - How many AI generations were needed?
   - How many were discarded/rewritten?
   - What could have been clearer in the spec to avoid rewrites?
   - Update the RFC with learnings for next time

**Gate 5 Checklist:**
- [ ] Code review checklist passes
- [ ] Architecture review passes
- [ ] Documentation is complete
- [ ] Token audit completed and learnings captured

---

## How to Use This Skill with AI

When entering prompts for AI code generation, structure them as:

```
Context: [paste relevant section of RFC + domain model]
Test to satisfy: [paste the specific test case]
Layer: [domain | application | infrastructure]
Constraints: [SOLID principles, no framework imports in domain, etc.]

Implement the code that makes this test pass.
```

This constrains the AI's output to a narrow, well-defined scope. The AI doesn't need to
guess architecture, naming, interfaces, or behavior — it's all in the context. This is
where the token savings compound.

---

## Quick Reference: When to Read What

| You're starting...          | Read first                              |
| --------------------------- | --------------------------------------- |
| A new project/feature       | This SKILL.md → `templates/RFC_TEMPLATE.md` |
| Domain modeling              | `references/DDD_GUIDE.md`              |
| Writing tests                | `references/TDD_GUIDE.md`              |
| Implementing code            | `references/CLEAN_ARCH_GUIDE.md`       |
| Reviewing for SOLID          | `references/SOLID_GUIDE.md`            |

---

## Anti-Patterns to Avoid

1. **"Just build it"** — Skipping Phase 1 to save time. This always costs more tokens later.
2. **Anemic domain model** — Entities that are just data bags with getters/setters. Logic
   belongs in the domain, not in use cases or controllers.
3. **Testing implementation** — Tests that break when you refactor internals. Test behavior
   and contracts, not structure.
4. **Framework-first thinking** — Choosing your database/framework before your domain model.
   The domain doesn't know or care about infrastructure.
5. **God use cases** — Use cases that do too many things. One use case = one user intention.
6. **Shared mutable state** — Value objects exist for a reason. If it doesn't have identity,
   make it immutable.
7. **Premature abstraction** — Don't create an interface for something that only has one
   implementation and no foreseeable second one. YAGNI still applies.
