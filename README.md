# Hotel Booking App

Cross-platform hotel booking client built with **Flutter**, **BLoC**, **GraphQL**, and **Clean Architecture**. The application is part of a full-stack booking platform with a dedicated GraphQL backend and React web client.

[![Flutter CI](https://github.com/Yaroslavgiv/hotel-booking-app/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/Yaroslavgiv/hotel-booking-app/actions/workflows/flutter-ci.yml)

## Product scope

- Android, iOS, and Windows clients
- Hotel and room discovery
- Availability checks for selected date ranges
- Room filtering by price and type
- Booking creation and cancellation
- User-aware booking flow
- Localization support
- GraphQL integration through a dedicated data source
- BLoC-based state management

## Architecture

The project follows feature-oriented Clean Architecture with explicit boundaries between domain, application, data, and presentation layers.

```text
lib/
├── core/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   └── presentation/
│   └── hotels/
│       ├── domain/
│       ├── application/
│       ├── data/
│       └── presentation/
├── l10n/
└── main.dart
```

### Dependency flow

```text
Presentation (BLoC / UI)
          ↓
     Application
       Use Cases
          ↓
        Domain
 Entities + Repository contracts
          ↑
         Data
 Repository implementations
          ↓
       GraphQL API
```

Key engineering decisions:

- **BLoC** keeps UI state transitions explicit and testable.
- **Use cases** represent application operations and isolate UI from data-access details.
- **Repository abstractions** keep the domain layer independent from GraphQL.
- **Feature-first organization** keeps the codebase scalable as new business capabilities are added.
- **GraphQL data source** owns transport-level communication and response mapping.

More details: [Architecture](docs/ARCHITECTURE.md).

## Full-stack system

```text
┌──────────────────────┐       ┌──────────────────────┐
│     Flutter App      │       │      React Web       │
│ BLoC + Clean Arch    │       │ React + Apollo       │
└──────────┬───────────┘       └──────────┬───────────┘
           │ GraphQL                      │ GraphQL
           └──────────────┬───────────────┘
                          ▼
               ┌──────────────────────┐
               │   Apollo Backend     │
               │ Services + Repos     │
               │ TypeScript + TypeORM │
               └──────────────────────┘
```

Related repositories:

- Backend: [Yaroslavgiv/hotel-booking-back](https://github.com/Yaroslavgiv/hotel-booking-back)
- Web: [Yaroslavgiv/hotel-booking-web](https://github.com/Yaroslavgiv/hotel-booking-web)

## Tech stack

- Flutter / Dart
- flutter_bloc
- Equatable
- GraphQL Flutter
- Provider for dependency wiring
- flutter_localizations / intl
- Mocktail
- Material Design

## Main flows

### Authentication

The app validates user details, stores authentication state in `AuthBloc`, and uses the current user to prefill booking information.

### Hotels and rooms

The client loads hotels through use cases and repository abstractions, displays availability state, opens hotel rooms, and filters rooms by price, type, and date range.

### Booking

The booking flow checks room availability before mutation, validates guest data and dates, creates bookings through GraphQL, refreshes state after successful operations, and supports cancellation.

### Windows overview

The desktop flow provides a compact hotel overview intended for operator-style usage and quick availability checks.

## Getting started

Prerequisites:

- Flutter SDK compatible with Dart `^3.9.2`
- running hotel booking GraphQL backend

```bash
git clone https://github.com/Yaroslavgiv/hotel-booking-app.git
cd hotel-booking-app
flutter pub get
flutter run
```

The backend repository contains the GraphQL API and local Docker setup.

## Quality gates

The CI pipeline validates every push and pull request with:

```bash
flutter pub get
flutter analyze
flutter test
```

Run locally:

```bash
flutter analyze
flutter test
```

## Testing strategy

The project is structured to support multiple testing layers:

- domain and use-case unit tests
- repository tests with mocked remote data sources
- BLoC tests for state transitions
- widget tests for presentation behavior
- integration tests for critical booking flows

The next quality milestone is expanding coverage around GraphQL failures, booking conflicts, BLoC state transitions, and end-to-end booking scenarios.

## Engineering roadmap

- strengthen typed error/failure handling
- separate booking capability into its own feature boundary
- formalize dependency injection composition
- expand BLoC and widget test coverage
- add integration tests for critical booking flows
- add production environment configuration
- add release build workflow

## License

This repository is maintained as a portfolio and engineering showcase project.
