# Flutter Clean Architecture + BLoC (Production Enforcement Spec)

## 1. ARCHITECTURE OVERVIEW

The project MUST follow **Clean Architecture** with **feature-first modularization**.

### Layers

- **Presentation** → UI, BLoC/Cubit, Widgets, Pages
- **Domain** → Pure business logic, entities, use cases, repository contracts
- **Data** → API, DB, DTO/models, repository implementations, data sources

### Dependency Rule

Dependencies flow ONLY inward:

```text
Presentation → Domain ← Data
```

Domain is the center and MUST NOT depend on Presentation or Data.

---

## 2. PROJECT STRUCTURE

```text
lib/
├── core/
│   ├── error/
│   ├── network/
│   ├── usecases/
│   ├── utils/
│   └── constants/
│
├── shared/
│   ├── widgets/
│   ├── extensions/
│   └── helpers/
│
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       │
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       │
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
│
└── injection_container.dart
```

---

## 3. DOMAIN LAYER RULES

### Allowed

- Entities
- UseCases
- Repository contracts

### Forbidden

- Flutter imports
- HTTP / DB logic
- JSON serialization
- Framework dependencies

### Rules

- Pure Dart only
- Must not know implementation details
- Must not know where data comes from

---

## 4. DATA LAYER RULES

### Allowed

- API calls
- Local DB access
- DTO models
- Repository implementations
- Data source implementations

### Responsibilities

- Convert raw data to domain entities
- Convert domain entities to data format when needed
- Handle external communication
- Implement domain repository contracts

### Forbidden

- Business logic decisions
- UI logic
- Direct dependency on presentation

---

## 5. PRESENTATION LAYER RULES

### Allowed

- BLoC / Cubit
- UI widgets
- Pages
- State classes
- Event classes

### Rules

- Must ONLY call UseCases
- Must NOT call repositories directly
- Must NOT call APIs directly
- Must NOT know data source implementation details

---

## 6. FEATURE-FIRST RULE

Each feature MUST be isolated under:

```text
features/<feature_name>/
```

### No cross-feature imports unless:

- Through a shared domain contract
- Through core/shared modules intentionally designed for reuse

### Forbidden

- Feature-to-feature direct coupling
- Shared “god modules”
- Random folders outside the structure

---

## 7. STATE MANAGEMENT RULES

### Default

- Use **BLoC** for complex flows
- Use **Cubit** only for trivial state

### Decision Rule

- If events exist → use BLoC
- If no events exist → Cubit is allowed

### State Rules

- States MUST be immutable
- States MUST be explicit and minimal
- Avoid unnecessary state explosion

---

## 8. USE CASE RULES

### Rule

Every business operation MUST be represented as a UseCase.

### Examples

- GetVehicleDetails
- UpdateProfile
- FetchOrders
- LoginUser

### Forbidden

- Direct repository calls from BLoC or UI
- Business logic hidden inside widgets
- Business logic hidden inside repository implementations

---

## 9. ERROR HANDLING SYSTEM

### Domain

- Uses `Failure`

### Data

- Uses `Exception`

### Flow

```text
Data → throws Exception
Repository → converts Exception to Failure
Domain → only sees Failure
Presentation → handles Failure via state
```

### Rules

- Exceptions stay in Data layer
- Failures represent domain-level problems
- Domain must never see raw exceptions

---

## 10. FUNCTIONAL ERROR PATTERN

All UseCases MUST return:

```dart
Either<Failure, Result>
```

### Rules

- No null-based error handling
- No silent failures
- No swallowing exceptions
- Always handle both success and failure explicitly

---

## 11. MODEL RULES

### Data Models / DTOs

- Live only in Data layer
- Handle JSON serialization
- Map to/from Domain entities

### Domain Entities

- Pure Dart
- No JSON logic
- No framework dependencies

---

## 12. BLoC RULES

### Structure

```text
bloc/
├── bloc.dart
├── event.dart
└── state.dart
```

### Rules

- BLoC must only interact with UseCases
- BLoC must emit states only
- BLoC must not import Data layer
- BLoC must not call APIs directly

---

## 13. DEPENDENCY INJECTION

All dependencies MUST be registered in:

```text
injection_container.dart
```

### Rules

- Use GetIt or equivalent
- No manual instantiation inside features
- No hidden dependencies
- All wiring must be centralized

---

## 14. CORE vs SHARED RULE

### core/

Use for:

- App-wide infrastructure
- Error handling
- Network layer
- Base use cases
- Constants
- Cross-cutting technical services

### shared/

Use for:

- Reusable UI components
- Common widgets
- Extensions
- Helpers

### Rule

- If it is infrastructure-level → core
- If it is reused UI or utility code → shared

---

## 15. FORBIDDEN PRACTICES

- Business logic in UI
- Skipping UseCases
- API calls in BLoC
- Importing Flutter in Domain
- Cross-feature coupling
- God BLoCs
- Unhandled failures
- Domain depending on Data
- Presentation depending on Data

---

## 16. TESTING RULES

### Domain

- Unit test entities and use cases
- Mock repository contracts

### Data

- Mock API / DB
- Test repository implementations
- Test mapping logic

### Presentation

- Test BLoC/Cubit with mocked UseCases
- Do not test UI implementation details through business logic tests

---

## 17. ACCEPTANCE CHECKLIST

Before any implementation:

- [ ] Domain is pure Dart
- [ ] No Flutter in Domain
- [ ] No direct API calls in UI/BLoC
- [ ] Presentation only uses UseCases
- [ ] Data implements Domain contracts
- [ ] Either<Failure, T> is used consistently
- [ ] Feature boundaries are respected
- [ ] Dependency flow is inward only
- [ ] No architecture leaks exist

---

## 18. FINAL ARCHITECTURAL TRUTH

Clean Architecture is valid ONLY if:

- Domain is isolated
- Dependencies flow inward
- Features are self-contained
- UseCases are the only entry point to business logic

If any rule is broken, the architecture is invalid and MUST be refactored.
