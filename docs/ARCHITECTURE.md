# Modular Clean Architecture, SOLID & DRY in Dart Monorepos

## Executive Summary
This document defines the architectural blueprint for building scalable, enterprise-grade Flutter/Dart applications using **Modular Clean Architecture**, **SOLID principles**, and **DRY (Don't Repeat Yourself)** engineering practices within a **Dart Workspace Monorepo**.

Unlike traditional monoliths or naive folder-by-feature setups, this architecture treats packages as decoupled, reusable **LEGO blocks**.

---

## 1. Architectural Layers & Separation of Concerns

Each module/feature is separated into three decoupled layers across package boundaries:

```
+-------------------------------------------------------------------+
|                        PRESENTATION LAYER                         |
|   (Flutter Widgets, State Management/BLoC/Notifier, UI Models)   |
+-------------------------------------------------------------------+
                                  |
                                  v  (Depends on Domain interfaces)
+-------------------------------------------------------------------+
|                           DOMAIN LAYER                            |
|   (Entities, Value Objects, Use Cases, Repository Contracts)      |
|   * ZERO dependencies on Flutter, Http, or External Frameworks * |
+-------------------------------------------------------------------+
                                  ^
                                  |  (Implements Domain interfaces)
+-------------------------------------------------------------------+
|                            DATA LAYER                             |
|   (DTOs/Models, Data Sources, Repository Implementations, Mappers)|
+-------------------------------------------------------------------+
```

### Layer Rules
1. **Domain Layer (`*_domain`)**:
   - Contains pure business logic: `Entities`, `ValueObjects`, `UseCases`, `Failures`, and `Repository Interfaces`.
   - **Rule**: Must remain pure Dart (`package:dart`). No Flutter, no Dio, no SharedPreferences, no SQFlite.
2. **Data Layer (`*_data`)**:
   - Implements domain repository interfaces (`RepositoryImpl`).
   - Handles network calls (`RemoteDataSource`), local caching (`LocalDataSource`), and serialization (`DTO` / Mappers).
   - Depends **only** on the corresponding `*_domain` package and shared core data packages.
3. **Presentation Layer (`*_presentation`)**:
   - Flutter UI components (`Widgets`, `Screens`), Controllers/States (e.g. `ChangeNotifier`, `Cubit`, `StateNotifier`).
   - Depends **only** on `*_domain` package (or `core_ui` for design system).
   - **Crucial Rule**: `*_presentation` NEVER imports `*_data` directly. Dependency Injection (DI) wires implementations at the app shell level (`apps/mobile_app`).

---

## 2. SOLID Principles Applied in Monorepo Design

- **Single Responsibility Principle (SRP)**:
  - Each package has one responsibility (`auth_domain` defines auth rules; `auth_data` fetches auth data; `auth_presentation` renders auth UI).
  - UseCases handle exactly one business action (e.g., `LoginUserUseCase`).
- **Open/Closed Principle (OCP)**:
  - Data sources and Repositories are interface-driven. To switch from REST to GraphQL or Firebase, add a new implementation in `*_data` without modifying `*_domain` or `*_presentation`.
- **Liskov Substitution Principle (LSP)**:
  - Mock and fake repositories seamlessly replace concrete implementations in testing because UI depends purely on repository abstractions.
- **Interface Segregation Principle (ISP)**:
  - Repositories expose only the methods required by feature use cases, rather than bloated god-interfaces.
- **Dependency Inversion Principle (DIP)**:
  - Domain does not depend on Data or Frameworks. Both Data and Presentation depend on Domain abstractions.

---

## 3. DRY (Don't Repeat Yourself) Without Coupling

To avoid duplication while maintaining isolation:
1. Shared foundational contracts live in `core_domain` (e.g., `UseCase<Type, Params>`, `Failure`, `Either`/`Result`).
2. Common network utilities, HTTP client contracts, and error handlers live in `core_data`.
3. Design System, typography, colors, and reusable UI components live in `core_ui`.
4. Domain entities and DTOs are kept separate:
   - DTOs (Data Transfer Objects) handle JSON parsing in Data layer.
   - Domain Entities represent immutable business models in Domain layer.
   - Mappers convert between DTOs and Entities.

---

## 4. LEGO Package Modular Monorepo Concept

In this approach, features are self-contained **LEGO bricks**:

```
apps/
  ├── mobile_app/         # Assembles LEGO blocks (App Shell, Router, DI)
  └── web_app/            # Alternative shell reusing same feature packages

packages/
  ├── core/               # Shared base packages
  │   ├── core_domain
  │   ├── core_data
  │   └── core_ui
  │
  └── features/           # Reusable feature LEGO blocks
      ├── auth/
      │   ├── auth_domain
      │   ├── auth_data
      │   └── auth_presentation
      └── blog/
          ├── blog_domain
          ├── blog_data
          └── blog_presentation
```

### Why Package-level Separation over Folder-level?
- **Strict Boundary Enforcement**: Dart analyzer prevents illegal cross-layer imports (e.g., `import 'package:auth_data/...'` inside `auth_presentation` causes a compile-time error if `auth_presentation` does not list `auth_data` in `pubspec.yaml`).
- **Fast Incremental Builds**: Modifying `auth_presentation` only invalidates presentation targets, leaving data/domain compilation cached.
- **Reusability across Shells**: Mobile, Web, CLI, or micro-apps can pick and mix feature packages as needed.
