# Clean Architecture Reference Guide

## Purpose

This guide defines the layer structure, dependency rules, and implementation patterns
for Clean Architecture. The goal is to keep business logic independent of frameworks,
databases, and delivery mechanisms — so the domain survives technology changes.

---

## The Dependency Rule

The single most important rule in Clean Architecture:

**Source code dependencies must point inward only.**

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

- **Domain** depends on NOTHING external. No framework imports. No DB drivers.
- **Application** depends only on Domain (interfaces/ports defined there).
- **Infrastructure** depends on Application and Domain. It implements ports.
- **Nothing inner knows about anything outer.**

---

## Layer Responsibilities

### Domain Layer (`src/domain/`)

**Contains:** Entities, aggregates, value objects, domain events, domain services,
repository interfaces (ports), external service interfaces (ports).

**Rules:**
- Zero external dependencies (no npm packages, no pip installs, no crate imports
  except the language standard library)
- All business logic lives here
- Defines ports (interfaces) that outer layers must implement
- Uses only primitive types or other domain types

**Structure:**
```
domain/
├── entities/           # Aggregate roots, entities, value objects
│   ├── order.ext
│   └── line_item.ext
├── events/             # Domain event definitions
│   ├── order_placed.ext
│   └── order_cancelled.ext
├── services/           # Domain services (cross-aggregate logic)
│   └── pricing_service.ext
└── ports/              # Interfaces for infrastructure
    ├── order_repository.ext
    └── payment_gateway.ext
```

### Application Layer (`src/application/`)

**Contains:** Use cases, input/output DTOs, application services.

**Rules:**
- Depends only on domain layer types and ports
- One use case = one user intention = one class/function
- Orchestrates domain objects but contains no business logic itself
- Handles transaction boundaries (start/commit/rollback)
- Validates input DTOs before calling domain
- Maps between DTOs and domain objects

**Structure:**
```
application/
├── usecases/
│   ├── place_order.ext         # PlaceOrderUseCase
│   ├── cancel_order.ext        # CancelOrderUseCase
│   └── get_order_details.ext   # GetOrderDetailsUseCase (query)
├── dtos/
│   ├── place_order_input.ext
│   ├── place_order_output.ext
│   └── order_details.ext
└── services/
    └── notification_service.ext  # Application-level coordination
```

**Use Case Pattern:**

```
class PlaceOrderUseCase:
    constructor(orderRepo: OrderRepository, paymentGateway: PaymentGateway)

    execute(input: PlaceOrderInput) -> PlaceOrderOutput:
        // 1. Validate input
        // 2. Load/create domain objects
        // 3. Execute domain logic (call methods on aggregates/services)
        // 4. Persist via repository port
        // 5. Emit events (if needed)
        // 6. Return output DTO
```

### Infrastructure Layer (`src/infrastructure/`)

**Contains:** Framework configurations, database implementations, HTTP controllers,
message queue consumers/producers, external API clients, DI container setup.

**Rules:**
- Implements domain ports (repository interfaces, external service interfaces)
- Contains ALL framework-specific code
- Maps between infrastructure types (DB rows, HTTP requests) and domain types
- This is the only layer that knows about specific technologies

**Structure:**
```
infrastructure/
├── persistence/
│   ├── postgres_order_repository.ext    # Implements OrderRepository port
│   ├── migrations/
│   └── orm_config.ext
├── http/
│   ├── controllers/
│   │   └── order_controller.ext
│   ├── routes.ext
│   └── middleware/
├── messaging/
│   ├── event_bus.ext
│   └── consumers/
├── external/
│   └── stripe_payment_gateway.ext       # Implements PaymentGateway port
└── config/
    ├── di_container.ext                 # Wires ports to adapters
    └── app_config.ext
```

### Shared / Cross-Cutting (`src/shared/`)

**Contains:** Logging interfaces, error types, utility functions.

**Rules:**
- Keep this minimal — most code should be in a specific layer
- Error types used across layers can live here
- Logging interface (not implementation) can live here
- DO NOT use this as a dumping ground

---

## Implementation Sequence

Follow this order strictly. Each step produces code that can be tested independently.

### Step 1: Domain Layer

Implement from the domain model document:
1. Value objects (simplest, no dependencies)
2. Entities and aggregate roots
3. Domain events
4. Domain services
5. Port interfaces (just the type signatures)

Run domain tests after each component. They should all pass.

### Step 2: Application Layer

Implement from the RFC use cases:
1. Input/output DTOs
2. Use cases (one at a time, simplest first)

Run application tests (with mocked ports) after each use case.

### Step 3: Infrastructure Layer

Implement from the RFC interface contracts:
1. Repository adapters (e.g., PostgresOrderRepository)
2. HTTP controllers/handlers
3. External service adapters
4. Message queue consumers/producers

Run adapter tests after each component.

### Step 4: Composition Root

Wire everything together:
1. Configure DI container — bind ports to adapters
2. Set up application entry point
3. Run full integration/E2E tests

---

## Crossing Layer Boundaries

### Inward (Infrastructure → Application → Domain)

**HTTP Request → Use Case:**
```
Controller receives HTTP request
  → Maps request body to Input DTO
  → Calls UseCase.execute(inputDTO)
  → Maps Output DTO to HTTP response
```

**Message → Use Case:**
```
Consumer receives message
  → Deserializes to Input DTO
  → Calls UseCase.execute(inputDTO)
  → Acks/nacks message based on result
```

### Outward (Domain → Infrastructure via Ports)

**Domain needs to persist:**
```
Domain defines: interface OrderRepository { save(order: Order): void }
Infrastructure implements: class PostgresOrderRepository implements OrderRepository
DI container binds: OrderRepository → PostgresOrderRepository
```

**Domain needs external service:**
```
Domain defines: interface PaymentGateway { charge(amount: Money): PaymentResult }
Infrastructure implements: class StripePaymentGateway implements PaymentGateway
DI container binds: PaymentGateway → StripePaymentGateway
```

---

## Common Violations & Fixes

| Violation | Example | Fix |
|-----------|---------|-----|
| Domain imports framework | `import { Entity } from 'typeorm'` in domain | Remove decorator/import, use plain classes |
| Use case contains business logic | `if (order.total > 1000) applyDiscount()` in use case | Move to `Order.applyDiscount()` in domain |
| Controller calls repository directly | `controller.get() { repo.findAll() }` | Create a use case, controller calls use case |
| Domain returns infrastructure types | Repository returns DB row objects | Map to domain objects in repository adapter |
| Shared module grows unbounded | 50+ files in shared/ | Move to appropriate layer or extract module |
| Direct aggregate references | `Order.customer: Customer` | Change to `Order.customerId: CustomerId` |

---

## Dependency Verification

After implementation, verify the dependency rule is not violated:

1. **Static analysis:** Check import statements in domain layer files. They should
   only import from other domain files or the language standard library.

2. **Architecture test (recommended):** Write a test that scans import statements
   and fails if a domain file imports from application or infrastructure.

3. **Manual review:** For each layer, list its imports and verify they only point inward.
