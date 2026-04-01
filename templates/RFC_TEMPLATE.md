# RFC-[NUMBER]: [Title]

| Field             | Value                                    |
| ----------------- | ---------------------------------------- |
| **Status**        | Draft / In Review / Approved / Superseded |
| **Author(s)**     |                                          |
| **Created**       | YYYY-MM-DD                               |
| **Last Updated**  | YYYY-MM-DD                               |
| **Stakeholders**  |                                          |
| **Related RFCs**  | RFC-XXX, RFC-YYY (if any)                |

---

## 1. Summary

<!-- One paragraph. What is this RFC about? What does it propose? -->

## 2. Motivation

<!-- Why is this needed? What problem does it solve? What happens if we don't do it? -->

### 2.1 Problem Statement

<!-- Concrete description of the current pain point or gap. -->

### 2.2 Goals

<!-- Bulleted list of what this RFC aims to achieve. Be specific and measurable. -->

- Goal 1
- Goal 2

### 2.3 Non-Goals

<!-- Explicitly state what this RFC does NOT aim to solve. This prevents scope creep. -->

- Non-goal 1
- Non-goal 2

---

## 3. Background & Context

<!-- Technical and business context needed to understand this RFC. Reference existing
     systems, prior art, domain knowledge. Assume the reader is technically competent
     but unfamiliar with this specific problem space. -->

---

## 4. Detailed Design

### 4.1 System Overview

<!-- High-level architecture. Describe the major components and how they interact.
     Include a diagram if helpful (Mermaid, ASCII, or reference an image). -->

### 4.2 Data Model

<!-- Define all entities, their attributes, types, and relationships.
     Use a table or schema notation. -->

| Entity      | Attribute    | Type      | Constraints          | Description           |
| ----------- | ------------ | --------- | -------------------- | --------------------- |
| Example     | id           | UUID      | PK, auto-generated   | Unique identifier     |
| Example     | name         | string    | required, max 255    | Human-readable name   |

### 4.3 API / Interface Contracts

<!-- For every external boundary (REST API, CLI, message queue, library API),
     define the full contract. -->

#### 4.3.1 [Interface Name]

**Endpoint / Method signature:**

```
[METHOD] /path/to/resource
```

**Request:**

```json
{
  "field": "value"
}
```

**Response (success):**

```json
{
  "field": "value"
}
```

**Response (error):**

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description"
  }
}
```

**Status codes / Return values:**

| Code/Value | Meaning                    |
| ---------- | -------------------------- |
| 200        | Success                    |
| 400        | Validation error           |
| 404        | Resource not found         |
| 409        | Conflict (duplicate, etc.) |

<!-- Repeat section 4.3.x for each interface -->

### 4.4 Business Rules & Invariants

<!-- List every business rule as a numbered item. These become test assertions. -->

1. **BR-001:** [Rule description]. Example: "An order cannot be placed if the user's account is suspended."
2. **BR-002:** [Rule description].

### 4.5 Domain Events

<!-- Events emitted by the system when state transitions occur. -->

| Event Name           | Trigger Condition          | Payload Shape                     |
| -------------------- | -------------------------- | --------------------------------- |
| `OrderPlaced`        | Order successfully created | `{ orderId, userId, items, total }` |

### 4.6 State Machines (if applicable)

<!-- Define states, transitions, and guards for stateful entities. -->

```
[Initial] --create--> [Pending] --approve--> [Active] --cancel--> [Cancelled]
                                  --reject---> [Rejected]
```

| From     | Event    | Guard              | To        | Side Effects            |
| -------- | -------- | ------------------ | --------- | ----------------------- |
| Pending  | approve  | reviewer.isAdmin   | Active    | Emit `OrderApproved`    |

---

## 5. Edge Cases & Error Handling

<!-- MANDATORY SECTION. Enumerate every known edge case. Each entry must specify
     the scenario, the expected behavior, and the error code/message if applicable. -->

| # | Scenario                          | Expected Behavior                      | Error Code   |
| - | --------------------------------- | -------------------------------------- | ------------ |
| 1 | Input exceeds max length          | Reject with validation error           | INVALID_INPUT |
| 2 | Concurrent duplicate requests     | Idempotency — second request is no-op  | —            |
| 3 | External service unavailable      | Retry 3x with exponential backoff      | SERVICE_UNAVAIL |
| 4 | Partial failure in batch          | Roll back entire batch, return details | BATCH_FAILED |
| 5 | [Add more as needed]              |                                        |              |

---

## 6. Non-Functional Requirements

### 6.1 Performance

| Metric             | Target         | Measurement Method          |
| ------------------ | -------------- | --------------------------- |
| Response latency   | p95 < 200ms    | APM / tracing               |
| Throughput          | 1000 req/s     | Load test                   |

### 6.2 Security

<!-- Authentication, authorization, data encryption, input validation rules. -->

### 6.3 Observability

<!-- Logging strategy, metrics to emit, tracing spans, alerting thresholds. -->

### 6.4 Scalability

<!-- Horizontal scaling strategy, data partitioning, caching approach. -->

### 6.5 Deployment & Rollout

<!-- How will this be deployed? Feature flags? Blue-green? Canary? Rollback plan? -->

---

## 7. Dependencies

<!-- External systems, libraries, services this RFC depends on. -->

| Dependency          | Version/API     | Purpose                | Risk/Fallback          |
| ------------------- | --------------- | ---------------------- | ---------------------- |
| PostgreSQL          | 15+             | Primary data store     | N/A                    |
| Stripe API          | v2023-10        | Payment processing     | Queue + retry          |

---

## 8. Alternatives Considered

### 8.1 [Alternative A]

<!-- Description, pros, cons, reason for rejection. -->

### 8.2 [Alternative B]

<!-- Description, pros, cons, reason for rejection. -->

---

## 9. Migration & Backward Compatibility

<!-- If this changes existing behavior: migration plan, data migration steps,
     backward compatibility guarantees, deprecation timeline. -->

---

## 10. Open Questions

<!-- Use [OPEN] tags. ALL must be resolved before this RFC is approved.

     [OPEN] Question 1: ...
     [OPEN] Question 2: ...
-->

---

## 11. Glossary

<!-- Define every domain-specific term used in this RFC. These become the
     ubiquitous language for the domain model. -->

| Term               | Definition                                                    |
| ------------------ | ------------------------------------------------------------- |
| [Term]             | [Definition]                                                  |

---

## 12. Appendices

### A. Sequence Diagrams

<!-- Include Mermaid or ASCII sequence diagrams for key flows. -->

### B. Wireframes / UI Mockups

<!-- Reference or embed if applicable. -->

### C. Research & References

<!-- Links to related documentation, articles, prior art. -->

---

## Revision History

| Date       | Author | Changes                    |
| ---------- | ------ | -------------------------- |
| YYYY-MM-DD |        | Initial draft              |
