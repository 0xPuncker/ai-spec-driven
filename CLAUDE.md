# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **methodology repository** for Spec-Driven Development — a structured software development approach that front-loads clarity before code generation. It contains reference guides, templates, and workflow definitions for building software using DDD (Domain-Driven Design), TDD (Test-Driven Development), Clean Architecture, and SOLID principles.

**This is not a codebase** — it's a knowledge base of development practices and templates.

## When to Use This Repository

Invoke this skill when users want to:
- Build a new feature, service, module, or application of non-trivial complexity
- Apply DDD, Clean Architecture, or SOLID principles
- Write specs before implementation
- Improve code quality and reduce AI token waste through better upfront design
- Create RFCs (Request for Comments) or domain models

**Do not use** for quick one-off scripts, simple bug fixes, or when users explicitly want to skip planning.

## Core Workflow: The Spec-Driven Pipeline

The methodology enforces a strict 6-phase pipeline:

1. **Phase 0: Intent Capture** — Understand the problem, actors, operations, scope
2. **Phase 1: RFC Specification** — Create formal specification using `templates/RFC_TEMPLATE.md`
3. **Phase 2: Domain Model** — Define bounded contexts, aggregates, entities, value objects using DDD
4. **Phase 3: Test Contracts** — Write tests before implementation using TDD principles
5. **Phase 4: Implementation** — Generate code following Clean Architecture layers
6. **Phase 5: Review & Refactor** — Quality gates, SOLID review, documentation

Each phase has a **gate** — specific artifacts that must exist before proceeding. Never skip gates.

## Key Reference Documents

| Document | Purpose | When to Read |
|----------|---------|--------------|
| `SKILL.md` | Main methodology document with complete workflow | Starting any new project/feature |
| `templates/RFC_TEMPLATE.md` | Template for RFC specifications | Phase 1: RFC Specification |
| `templates/DOMAIN_MODEL_TEMPLATE.md` | Template for domain model documents | Phase 2: Domain Modeling |
| `references/DDD_GUIDE.md` | Domain-Driven Design workflow and concepts | Identifying bounded contexts, aggregates |
| `references/TDD_GUIDE.md` | Test-Driven Development strategy | Phase 3: Writing test contracts |
| `references/CLEAN_ARCH_GUIDE.md` | Layer structure and dependency rules | Phase 4: Implementation |
| `references/SOLID_GUIDE.md` | Code review checklist for each principle | Phase 5: Review & Refactor |

## Key Concepts

### Clean Architecture Layers

```
┌─────────────────────────────────────────────┐
│           Infrastructure Layer              │
│  (frameworks, DB, HTTP, messaging, UI)      │
│  ┌─────────────────────────────────────┐    │
│  │        Application Layer            │    │
│  │  (use cases, orchestration, DTOs)   │    │
│  │  ┌─────────────────────────────┐    │    │
│  │  │       Domain Layer          │    │    │
│  │  │  (entities, value objects,  │    │    │
│  │  │   events, ports, services)  │    │    │
│  │  └─────────────────────────────┘    │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

**The Dependency Rule:** Dependencies point inward ONLY. Domain has zero external dependencies.

### DDD Core Patterns

- **Bounded Context** — A boundary within which a particular domain model applies
- **Aggregate** — Cluster of domain objects treated as a single unit for data changes
- **Entity** — Object with unique identity that persists across state changes
- **Value Object** — Immutable object defined by its attributes, not identity
- **Domain Event** — Record of something that happened (past tense naming)
- **Repository (Port)** — Interface defined in domain, implemented in infrastructure

### SOLID Principles

- **S**ingle Responsibility — One reason to change
- **O**pen/Closed — Open for extension, closed for modification
- **L**iskov Substitution — Subtypes must be substitutable
- **I**nterface Segregation — Clients shouldn't depend on unused interfaces
- **D**ependency Inversion — Depend on abstractions, not concretions

## Using This Methodology with AI

When generating code with AI, structure prompts as:

```
Context: [paste relevant section of RFC + domain model]
Test to satisfy: [paste the specific test case]
Layer: [domain | application | infrastructure]
Constraints: [SOLID principles, no framework imports in domain, etc.]

Implement the code that makes this test pass.
```

This constrains AI output to a narrow scope, improving first-shot accuracy from ~30-40% to ~80%.

## Common Anti-Patterns to Avoid

1. **"Just build it"** — Skipping Phase 1 (RFC) always costs more tokens later
2. **Anemic domain model** — Entities as data bags with getters/setters; logic belongs in domain
3. **Testing implementation** — Tests that break on refactoring; test behavior, not structure
4. **Framework-first thinking** — Choosing DB/framework before domain model
5. **God use cases** — Use cases doing too much; one use case = one user intention
6. **Shared mutable state** — Use value objects for concepts without identity

## File Structure

```
.
├── SKILL.md                    # Main methodology document
├── CLAUDE.md                   # This file
├── references/                 # Detailed guides for each practice
│   ├── CLEAN_ARCH_GUIDE.md
│   ├── DDD_GUIDE.md
│   ├── TDD_GUIDE.md
│   └── SOLID_GUIDE.md
└── templates/                  # Document templates for the workflow
    ├── RFC_TEMPLATE.md
    └── DOMAIN_MODEL_TEMPLATE.md
```

## No Build System

This repository has no build tools, tests, or package management — it's pure documentation and templates. To apply this methodology, copy the templates to your project and follow the workflow in `SKILL.md`.
