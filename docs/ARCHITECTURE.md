# Architecture

## Goals

The Flutter client is designed around four goals: explicit business boundaries, testability, replaceable infrastructure, and predictable state management.

## Layers

### Domain

Contains business entities, value objects, and repository contracts. Domain code must not depend on Flutter UI or GraphQL implementation details.

### Application

Contains use cases representing application operations such as loading hotels, loading rooms, checking availability, creating bookings, and cancelling bookings.

### Data

Contains remote data sources and repository implementations. GraphQL-specific concerns stay behind repository contracts so the rest of the application does not depend on transport details.

### Presentation

Contains pages, widgets, and BLoCs. BLoCs coordinate use cases and expose explicit states to the UI.

## Dependency rule

Dependencies point toward the domain. Presentation depends on application abstractions; data implements domain contracts; domain does not know about GraphQL, Flutter widgets, or concrete infrastructure.

```text
UI -> BLoC -> Use Case -> Repository contract
                              ^
                              |
                    Repository implementation
                              |
                         GraphQL source
```

## State management

BLoC is the primary state-management approach. A BLoC should own one cohesive state machine and delegate business operations to use cases instead of directly performing network access.

## Error handling target

Transport exceptions should be translated at the data boundary into application/domain failures. Presentation should receive meaningful failure types rather than GraphQL client exceptions.

Target model:

```text
GraphQL exception
      ↓
RemoteDataSource
      ↓
Repository implementation
      ↓
Failure
      ↓
Use case / BLoC
      ↓
User-facing state
```

## Testing pyramid

1. Unit tests for entities, value objects, use cases, and mapping.
2. Repository tests with mocked data sources.
3. BLoC tests for state transitions and error paths.
4. Widget tests for critical presentation behavior.
5. Integration tests for booking and cancellation flows.

## Evolution

As the application grows, bookings should become a separate feature boundary and dependency construction should move to a dedicated composition root. Infrastructure such as environment configuration, logging, and failure mapping belongs in `core` rather than feature UI code.
