# TDD Reference Guide

## Purpose

This guide defines the testing strategy for spec-driven development. Tests are written
BEFORE implementation and serve as executable contracts derived from the RFC and domain
model. The goal: when you hand AI a failing test, it generates an implementation that
passes — first try.

---

## The Testing Pyramid

```
        /  E2E  \          ← Few: critical user journeys only
       / Adapter \         ← Moderate: real infra (DB, HTTP, queues)
      / Application\       ← Moderate: use cases with mocked ports
     /   Domain     \      ← Many: pure logic, no dependencies, fast
    ------------------
```

Write tests top-down in this document, but implement bottom-up (domain first).

---

## Test Naming Convention

Tests should read as behavior specifications. Use this pattern:

```
[UnitUnderTest]_[Scenario]_[ExpectedBehavior]

Examples:
  Order_WhenItemsExceedMaxQuantity_ShouldRejectWithError
  EmailAddress_WithInvalidFormat_ShouldThrowValidationError
  PlaceOrderUseCase_WhenUserIsSuspended_ShouldReturnForbidden
  OrderRepository_WhenOrderExists_ShouldReturnOrder
```

Alternative (BDD-style):

```
describe "[Unit]"
  it "should [behavior] when [condition]"

Examples:
  describe "Order"
    it "should reject items exceeding max quantity"
    it "should calculate total as sum of line subtotals"
```

Use whichever convention fits your stack, but be consistent within a project.

---

## Test Structure: Given-When-Then

Every test follows this structure:

```
// GIVEN: Set up preconditions
//   - Create domain objects with known state
//   - Configure mocks/stubs if needed

// WHEN: Execute the operation under test
//   - Call exactly ONE method/function

// THEN: Assert postconditions
//   - Check return value
//   - Check state changes
//   - Check events emitted
//   - Check errors raised
```

**Rules:**
- One logical assertion per test (multiple `assert` calls are fine if they verify one concept)
- No conditional logic in tests (no if/else)
- No loops in tests (parameterized tests are fine)
- Tests must be independent — no shared mutable state between tests

---

## Layer-by-Layer Test Strategy

### Domain Layer Tests

**What to test:** Aggregate invariants, value object validation, domain service logic.
**Dependencies:** NONE. Pure functions and objects. No mocks needed.
**Speed:** Instant. These should run in milliseconds.

**Derive from:**
- RFC Section 4.4 (Business Rules & Invariants)
- Domain Model invariants (INV-xxx)
- Value object validation rules

**Template:**

```
test "[AggregateName]_[Invariant]_[Behavior]":
    // GIVEN
    aggregate = create [AggregateName] with [valid initial state]

    // WHEN
    result = aggregate.[method]([input that triggers invariant])

    // THEN
    assert result is [expected outcome]
    // OR
    assert throws [specific error] with [specific message/code]
```

**Coverage targets:**
- Every invariant from the domain model (INV-xxx) has ≥1 test
- Every value object constructor validates and rejects invalid input
- Every domain event is emitted under correct conditions
- Every state transition in state machines is tested (valid + invalid)

### Application Layer Tests (Use Cases)

**What to test:** Orchestration logic, input validation, authorization checks.
**Dependencies:** Domain objects (real) + Ports (mocked/stubbed).
**Speed:** Fast. No I/O.

**Derive from:**
- RFC Section 4.3 (API/Interface Contracts)
- RFC Section 5 (Edge Cases)
- Use case definitions from the RFC

**Template:**

```
test "[UseCaseName]_[Scenario]_[Behavior]":
    // GIVEN
    mockRepo = create mock of [RepositoryPort]
    mockRepo.[method] returns [known value]
    useCase = create [UseCaseName] with mockRepo

    // WHEN
    result = useCase.execute([input DTO])

    // THEN
    assert result equals [expected output DTO]
    assert mockRepo.[method] was called with [expected args]
    // If events: assert [event] was emitted
```

**Coverage targets:**
- Happy path for every use case
- Every error path from the RFC edge cases table
- Authorization/permission checks (if applicable)
- Input validation (null, empty, boundary values)

### Adapter Layer Tests

**What to test:** That infrastructure implementations satisfy port contracts.
**Dependencies:** Real infrastructure (test DB, test HTTP server, test queue).
**Speed:** Slower. Use test containers or in-memory alternatives where possible.

**Derive from:**
- Repository interface definitions from domain model
- HTTP endpoint contracts from RFC
- Message format contracts from RFC

**Template:**

```
test "[AdapterName]_[PortMethod]_[Behavior]":
    // GIVEN
    adapter = create [Adapter] with [test infrastructure]
    seed [test data] into [test infrastructure]

    // WHEN
    result = adapter.[method]([input])

    // THEN
    assert result equals [expected domain object]
    // For writes: assert [test infrastructure] contains [expected state]
```

**Coverage targets:**
- Every repository method defined in the domain port
- Mapping correctness (DB row → domain object, and back)
- Edge cases: not found, duplicate, concurrent modification

### E2E / Integration Tests

**What to test:** Critical user journeys end-to-end through the full stack.
**Dependencies:** Full application (or close to it).
**Speed:** Slowest. Run these last, keep them few.

**Derive from:**
- RFC Section 4.3 (API contracts — request/response examples)
- Key user stories or acceptance criteria

**Coverage targets:**
- Only the most critical happy paths (3-5 max for a typical feature)
- One critical error path

---

## Writing Tests Before Implementation

The key insight: you can write tests before ANY production code exists. Here's how:

1. **Define interfaces first.** Write the port/interface/trait/protocol definitions
   from the domain model. These are type signatures only — no implementation.

2. **Write domain tests.** Instantiate domain objects (which don't exist yet) and
   assert behavior. The test won't compile/run, but it specifies what to build.

3. **Write use case tests.** Create mocks of the ports and test the use case
   orchestration. Again, the use case class doesn't exist yet.

4. **Hand each test to AI** with this prompt structure:

```
Here is a failing test:
[paste test]

Here is the interface it depends on:
[paste interface/port definition]

Here are the domain rules it must enforce:
[paste relevant invariants from domain model]

Implement the minimum code to make this test pass.
Do not add any functionality beyond what the test requires.
```

This is the most token-efficient way to use AI for code generation. The test
constrains the output completely.

---

## Test Data Strategy

**Use Builder or Factory patterns** for creating test data:

```
// Instead of:
order = Order(id="123", user_id="456", items=[...], status="pending", ...)

// Use:
order = OrderBuilder().withStatus("pending").withItems(3).build()
```

**Principles:**
- Test data should be the minimum needed to exercise the behavior
- Use meaningful values, not random data (unless testing randomness)
- Avoid sharing test data between tests — each test creates its own
- For adapter tests, use database seeding/fixtures with known data

---

## Red-Green-Refactor with AI

The classic TDD cycle, adapted for AI-assisted development:

1. **RED:** Write a failing test. Verify it fails for the right reason
   (missing implementation, not a test bug).

2. **GREEN:** Prompt AI with the test + context. AI generates implementation.
   Run the test. If it passes → move on. If it fails → provide the error
   to AI for correction (this is a focused, cheap prompt).

3. **REFACTOR:** Review the AI-generated code against SOLID principles.
   If it needs restructuring, refactor manually or prompt AI with specific
   refactoring instructions. Run tests again to confirm nothing broke.

**Token savings:** By providing a failing test + precise context, the AI
generates correct code ~80% of the time on the first attempt. Without
tests, that rate drops to ~30-40%, requiring multiple correction rounds.
