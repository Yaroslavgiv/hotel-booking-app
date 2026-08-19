# Architecture

## Overview

The Flutter client is organized as a feature-oriented Clean Architecture application. Business rules are kept independent from Flutter UI and GraphQL transport details, while BLoC coordinates presentation state.

```text
Presentation (Pages / Widgets / BLoC)
                 |
                 v
Application (Use Cases)
                 |
                 v
Domain (Entities / Repository Contracts)
                 ^
                 |
Data (Repository Implementations / GraphQL Data Sources)
                 |
                 v
          GraphQL Backend
```

## Dependency rule

Dependencies point inward. The domain layer does not depend on Flutter, GraphQL, or concrete infrastructure. Data implementations satisfy repository contracts defined by the domain layer.

## Layers

### Domain

Contains business entities, value objects and repository contracts. This layer defines what the application can do without describing transport or UI details.

### Application

Use cases represent individual application operations such as loading hotels, loading rooms, checking availability, creating bookings and cancelling bookings.

### Data

GraphQL data sources communicate with the backend. Repository implementations translate transport data and failures into concepts consumed by the application and domain layers.

### Presentation

Pages and widgets render state. BLoCs own asynchronous UI workflows and expose explicit states rather than placing business logic inside widgets.

## State management

BLoC is the primary state-management approach. Separate BLoCs keep authentication, hotel lists, room details and desktop overview flows isolated and testable.

## Design principles

- Single Responsibility: UI, orchestration, business rules and transport concerns are separated.
- Dependency Inversion: presentation and use cases depend on abstractions rather than GraphQL implementations.
- Testability: use cases and BLoCs can be exercised with repository mocks.
- Feature orientation: related domain, data and presentation code is colocated under a feature boundary.
- Explicit boundaries: GraphQL remains an infrastructure concern rather than leaking through the UI.

## Evolution roadmap

The architecture is intentionally prepared for further production-oriented improvements:

1. central dependency composition under `app/di`;
2. typed failure hierarchy and GraphQL error mapping;
3. environment-specific API configuration;
4. stronger BLoC, widget and integration coverage;
5. observability and performance instrumentation;
6. generated typed GraphQL operations where appropriate.
