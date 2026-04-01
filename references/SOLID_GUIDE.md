# SOLID Principles Review Guide

## Purpose

Use this guide as a review checklist after implementing each layer. For every class,
module, or function, run through the five checks below. If any fails, refactor before
moving on.

---

## S — Single Responsibility Principle

**"A class should have only one reason to change."**

### The Test

Ask: "If I describe what this class does, do I use the word 'and'?"

- "This class **creates orders and sends notifications**" → VIOLATION (two reasons to change)
- "This class **creates orders**" → OK

### How to Fix

Extract the second responsibility into its own class. Common splits:
- Validation logic → dedicated Validator
- Formatting/serialization → dedicated Mapper/Serializer
- Side effects (email, logging) → dedicated service behind an interface

### Review Checklist

- [ ] Can you describe the class's purpose in one sentence without "and"?
- [ ] Does it have ≤ 1 reason to change?
- [ ] Are unrelated methods grouped together? (If yes, split)
- [ ] Is the class under ~200 lines? (Size isn't a rule, but large classes often violate SRP)

---

## O — Open/Closed Principle

**"Software entities should be open for extension, closed for modification."**

### The Test

Ask: "Can I add new behavior without changing existing code?"

- Adding a new payment method requires editing a giant `if/else` chain → VIOLATION
- Adding a new payment method means creating a new class implementing `PaymentStrategy` → OK

### How to Fix

Use polymorphism (strategy pattern, interface implementations) instead of conditionals.
Define a contract (interface/abstract class), implement variants, and let the caller
work with the abstraction.

### Review Checklist

- [ ] Are there large `if/else` or `switch/case` blocks based on type? (Extract to strategy)
- [ ] Can new variants be added without modifying existing classes?
- [ ] Are extension points defined via interfaces/abstractions?

---

## L — Liskov Substitution Principle

**"Subtypes must be substitutable for their base types without altering correctness."**

### The Test

Ask: "If I swap this implementation for another one of the same interface, does everything
still work correctly?"

- A `ReadOnlyRepository` that throws on `save()` but implements `Repository` → VIOLATION
- A `PostgresRepository` and `InMemoryRepository` both correctly implement `Repository` → OK

### How to Fix

- Don't inherit/implement interfaces you can't fully satisfy
- Split large interfaces into smaller ones (see ISP below)
- Ensure preconditions aren't strengthened and postconditions aren't weakened in subtypes

### Review Checklist

- [ ] Do all implementations of an interface fulfill its complete contract?
- [ ] Can any implementation be swapped with another without breaking callers?
- [ ] Do subtypes throw unexpected exceptions not declared in the base type?
- [ ] Do subtypes silently ignore operations they can't perform?

---

## I — Interface Segregation Principle

**"Clients should not be forced to depend on interfaces they do not use."**

### The Test

Ask: "Does this interface have methods that some implementations leave empty or throw
NotImplemented for?"

- `UserService` with `create()`, `delete()`, `generateReport()`, `sendEmail()` → VIOLATION
- `UserWriter` with `create()`, `delete()` and `ReportGenerator` with `generate()` → OK

### How to Fix

Split large interfaces into focused ones. Each interface represents a role or capability.
A class can implement multiple interfaces.

### Review Checklist

- [ ] Does any implementation have empty/no-op/throwing methods for interface methods?
- [ ] Are interfaces focused on a single role or capability?
- [ ] Do callers use all methods of the interfaces they depend on?
- [ ] Are "fat" interfaces (5+ methods) justified, or should they be split?

---

## D — Dependency Inversion Principle

**"High-level modules should not depend on low-level modules. Both should depend on
abstractions."**

### The Test

Ask: "Does this class instantiate its own dependencies, or receive them?"

- `class OrderService { constructor() { this.db = new PostgresClient() } }` → VIOLATION
- `class OrderService { constructor(repo: OrderRepository) { this.repo = repo } }` → OK

### How to Fix

1. Define an interface (port) in the domain/application layer
2. Implement it in the infrastructure layer
3. Inject the implementation via constructor (dependency injection)
4. Wire it in the composition root (DI container)

### Review Checklist

- [ ] Are all dependencies injected via constructor (or method parameters)?
- [ ] Does the class depend on interfaces/abstractions, not concrete classes?
- [ ] Is `new ConcreteClass()` only used in the composition root (DI wiring)?
- [ ] Can you swap implementations without touching the class that uses them?

---

## Quick SOLID Audit

For each class/module, fill in this table:

| Principle | Question | Pass? | Notes |
|-----------|----------|-------|-------|
| **S** | One reason to change? | ☐ | |
| **O** | Extensible without modification? | ☐ | |
| **L** | Implementations fully substitutable? | ☐ | |
| **I** | Interfaces focused and minimal? | ☐ | |
| **D** | Depends on abstractions, injected? | ☐ | |

If any check fails, refactor BEFORE proceeding to the next component.

---

## SOLID in the Context of Clean Architecture

| Layer | Most Common SOLID Violations |
|-------|------|
| **Domain** | Anemic entities (SRP — logic in wrong place), fat aggregate interfaces (ISP) |
| **Application** | God use cases doing too much (SRP), use cases calling concrete infra (DIP) |
| **Infrastructure** | Controllers with business logic (SRP), adapters not substitutable (LSP) |

---

## When NOT to Apply SOLID Rigidly

SOLID is a set of guidelines, not religious commandments. Pragmatism matters:

- **Don't create interfaces for one-implementation scenarios** unless you foresee a
  second implementation or need it for testing. YAGNI still applies.
- **Small scripts and utilities** don't need full SOLID treatment. A 30-line script
  can be procedural.
- **Performance-critical code** sometimes requires coupling for efficiency. Document
  the trade-off.
- **Prototypes and spikes** are meant to be thrown away. Don't gold-plate them.

The key: SOLID is a review tool for production code, not a blocker for exploration.
