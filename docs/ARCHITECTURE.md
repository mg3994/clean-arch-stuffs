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

## 2. End-to-End Data Flow Diagram

```
 [ USER ACTION ]
        |
        v
 [ LoginScreen ] (Widget)
        |
        v calls login(email, password)
 [ AuthController ] (State Notifier)
        |
        v executes LoginUser(LoginParams)
 [ LoginUser ] (UseCase - Domain Layer)
        |
        v calls repository.login()
 [ AuthRepositoryImpl ] (Data Layer)
        |
        +-----> [ AuthRemoteDataSource ] ---> (Network Client -> REST API)
        |                 |
        |                 v returns UserDto
        +-----> [ AuthLocalDataSource ] ----> (Cache UserDto locally)
        |                 |
        |                 v UserDto.toDomain()
        v returns Result<User> (Domain Entity)
 [ AuthController ] Updates AuthState
        |
        v notifies listeners
 [ LoginScreen ] Renders Success UI
```

---

## 3. Cross-Feature Communication & Navigation Strategy

When Feature A (`auth`) needs to trigger or navigate to Feature B (`blog`), **`auth_presentation` must NEVER import `blog_presentation` directly**.

### Communication Patterns:

#### Pattern 1: App Shell Callbacks / Router Delegation
The feature widget exposes callbacks for navigation events. The **App Shell (`apps/mobile_app`)** handles navigation:
```dart
// Inside auth_presentation:
class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess; // Callback delegated to shell
  const LoginScreen({super.key, required this.onLoginSuccess});
}

// Inside apps/mobile_app/lib/main.dart:
LoginScreen(
  onLoginSuccess: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BlogFeedScreen(...)),
    );
  },
)
```

#### Pattern 2: Shared Domain Event Bus or Core Contracts
If two features need to exchange state asynchronously (e.g. `auth` state changes affecting `cart` feature), expose a contract in `core_domain` or depend on a domain stream provided by DI:
```dart
// Shared contract in core_domain:
abstract class UserSessionStream {
  Stream<User?> get onSessionChanged;
}
```

---

## 4. Comprehensive Do's & Don'ts Guide

### Clean Architecture & Layering

| Category | DO ✅ | DON'T ❌ |
| :--- | :--- | :--- |
| **Domain Layer** | **DO** keep `*_domain` pure Dart. Keep zero framework or Flutter SDK imports. | **DON'T** import `package:flutter`, `dio`, `shared_preferences`, or data models into `*_domain`. |
| **Domain Layer** | **DO** define repository contracts as abstract interfaces in `*_domain`. | **DON'T** write concrete database or network logic inside `*_domain`. |
| **Data Layer** | **DO** use Data Transfer Objects (DTOs) with explicit mappers (`toEntity()`, `fromEntity()`). | **DON'T** leak API JSON keys or HTTP response structures directly into domain entities. |
| **Data Layer** | **DO** implement domain repository interfaces inside `*_data`. | **DON'T** expose data sources or DTOs outside the `*_data` package. |
| **Presentation Layer**| **DO** consume `UseCase` objects or domain entities in controllers and UI widgets. | **DON'T** import `*_data` packages or instantiate repository implementations in widgets. |
| **Presentation Layer**| **DO** handle UI state transitions explicitly (e.g. loading, success, failure). | **DON'T** perform business logic or data transformation directly inside `Widget.build()`. |
| **App Shell** | **DO** register repository implementations and UseCases in `apps/<shell>/lib/di/`. | **DON'T** duplicate dependency injection containers across individual feature packages. |

---

### SOLID Principles in Action

| Principle | DO ✅ | DON'T ❌ |
| :--- | :--- | :--- |
| **Single Responsibility (SRP)** | **DO** write focused UseCases handling a single business action (e.g., `LoginUser`). | **DON'T** create bloated "God UseCases" or "God Services" containing dozens of unrelated methods. |
| **Open/Closed (OCP)** | **DO** extend behavior by implementing new repository interfaces or data sources. | **DON'T** modify domain entities or contracts to support a new database or API payload format. |
| **Liskov Substitution (LSP)** | **DO** ensure mock and fake repositories conform strictly to domain repository contracts. | **DON'T** throw `UnimplementedError` in repository methods used during production runtime. |
| **Interface Segregation (ISP)**| **DO** create small, targeted repository contracts for specific feature boundaries. | **DON'T** force presentation modules to depend on huge interfaces with methods they do not use. |
| **Dependency Inversion (DIP)** | **DO** depend on abstractions (`AuthRepository`). | **DON'T** depend directly on concrete classes (`AuthRepositoryImpl` or `DioRemoteDataSource`). |

---

### DRY (Don't Repeat Yourself) Guidelines

| Aspect | DO ✅ | DON'T ❌ |
| :--- | :--- | :--- |
| **Shared Logic** | **DO** extract reusable failures, Result types, and UseCase interfaces into `core_domain`. | **DON'T** copy-paste `Result` or `Failure` classes into individual feature packages. |
| **Design System** | **DO** define colors, typography, buttons, and inputs in `core_ui`. | **DON'T** re-define primary colors or custom buttons across multiple feature presentation packages. |
| **DTO Mappers** | **DO** keep mapping logic in `*_data` (or extension methods on DTOs). | **DON'T** duplicate JSON parsing logic in widgets or state controllers. |

---

## 5. Layer-by-Layer Testing Strategy

```
+------------------------------------------------------------------------------------+
| Layer                 | Test Type               | Tooling                          |
+------------------------------------------------------------------------------------+
| Presentation Layer    | Widget & Controller     | flutter_test, Mocktail/Mockito    |
| Domain Layer          | Unit Tests (Pure Dart)  | test / flutter_test              |
| Data Layer            | Unit & Data Source      | test / flutter_test, MockAdapter |
| Shared Utilities      | Unit Tests              | test / flutter_test              |
| App Shell Integration | Integration Tests       | integration_test                 |
+------------------------------------------------------------------------------------+
```

1. **Domain Tests**: Test business invariants, validation rules, and UseCase invocation logic against mock repositories. Fast, zero-dependency execution.
2. **Data Tests**: Test DTO JSON deserialization, mapper conversions, local caching, and repository handling of network errors / HTTP status codes.
3. **Presentation Tests**: Test state controller transitions (`initial -> loading -> loaded / error`) and widget rendering response to state updates.

---

## 6. LEGO Package Modular Monorepo Concept

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
  ├── shared/             # Modular external/internal shared service packages
  │   └── logger_service/
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
