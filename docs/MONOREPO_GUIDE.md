# Dart Workspace Monorepo Strategy & Configuration

## Overview
Starting with **Dart 3.5+**, Dart includes native **Workspace support**. This eliminates the need for third-party monorepo tools for dependency resolution and package linking.

---

## 1. Directory Structure

```
.
├── pubspec.yaml                 # Root Workspace configuration
├── docs/                        # Monorepo architecture & guidelines docs
├── apps/                        # Main application shells / entry points
│   └── mobile_app/
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── main.dart        # Entry point: DI wiring, Routing, App initialization
│       │   └── di/              # Service Locator / Dependency Injection container
│       └── test/
└── packages/                    # Modular LEGO packages
    ├── core/                    # Core foundation packages
    │   ├── core_domain/
    │   │   ├── pubspec.yaml
    │   │   └── lib/             # Base Entities, Failures, UseCase contracts
    │   ├── core_data/
    │   │   ├── pubspec.yaml
    │   │   └── lib/             # Base Http client interfaces, Network DTO adapters
    │   └── core_ui/
    │       ├── pubspec.yaml
    │       └── lib/             # Design Tokens, Core Buttons, Input Fields, Themes
    └── features/                # Domain-Driven Feature packages
        ├── auth/
        │   ├── auth_domain/     # Auth Entities, ValueObjects, AuthRepository interface
        │   ├── auth_data/       # AuthDTO, AuthRemoteDataSource, AuthRepositoryImpl
        │   └── auth_presentation/# LoginScreen, AuthController/Cubit, AuthState
        └── blog/
            ├── blog_domain/
            ├── blog_data/
            └── blog_presentation/
```

---

## 2. Pubspec Configuration Rules (Dart 3.5+ Workspaces)

### A. Root `pubspec.yaml`
The root pubspec defines the workspace members and minimum SDK requirement.

```yaml
name: monorepo_root
environment:
  sdk: '>=3.5.0 <4.0.0'

workspace:
  - apps/mobile_app
  - packages/core/core_domain
  - packages/core/core_data
  - packages/core/core_ui
  - packages/features/auth/auth_domain
  - packages/features/auth/auth_data
  - packages/features/auth/auth_presentation
  - packages/features/blog/blog_domain
  - packages/features/blog/blog_data
  - packages/features/blog/blog_presentation
```

### B. Workspace Member `pubspec.yaml`
Every package in the workspace must declare `resolution: workspace`. Intra-workspace dependencies are declared without version specifiers.

Example for `packages/features/auth/auth_data/pubspec.yaml`:
```yaml
name: auth_data
environment:
  sdk: '>=3.5.0 <4.0.0'

resolution: workspace

dependencies:
  core_domain:
  core_data:
  auth_domain:
```

Example for `packages/features/auth/auth_presentation/pubspec.yaml`:
```yaml
name: auth_presentation
environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: ">=3.0.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  core_domain:
  core_ui:
  auth_domain:
```

Example for `apps/mobile_app/pubspec.yaml`:
```yaml
name: mobile_app
environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: ">=3.0.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  core_domain:
  core_data:
  core_ui:
  auth_domain:
  auth_data:
  auth_presentation:
  blog_domain:
  blog_data:
  blog_presentation:
```

---

## 3. Layer Dependency Matrix

| Package Category | Can Depend On | MUST NOT Depend On |
| :--- | :--- | :--- |
| `core_domain` | Pure Dart packages | `core_data`, `core_ui`, Features, Flutter SDK |
| `core_data` | `core_domain`, Dio/Http | `core_ui`, Feature packages, Flutter SDK |
| `core_ui` | `core_domain`, Flutter SDK | `core_data`, Feature data/domain packages |
| `<feature>_domain` | `core_domain` | `<feature>_data`, `<feature>_presentation`, Flutter SDK |
| `<feature>_data` | `core_domain`, `core_data`, `<feature>_domain` | `<feature>_presentation`, Flutter SDK |
| `<feature>_presentation` | `core_domain`, `core_ui`, `<feature>_domain`, Flutter SDK | `<feature>_data` |
| `apps/*` (App Shell) | All `core_*` and `<feature>_*` packages | None (App Shell is the assembler) |

---

## 4. How to Add a New Feature Module (Step-by-Step)

1. **Create Feature Packages**:
   - Create directory `packages/features/<feature_name>/`
   - Add `<feature_name>_domain`, `<feature_name>_data`, and `<feature_name>_presentation`.
2. **Register in Root `pubspec.yaml`**:
   - Add the paths to the `workspace:` list in the root `pubspec.yaml`.
3. **Set Up `pubspec.yaml` in Package Directories**:
   - Set `resolution: workspace` and specify necessary dependencies.
4. **Resolve Dependencies**:
   - Run `dart pub get` from root.
5. **Implement Architecture**:
   - `domain`: Define entities and repository interfaces.
   - `data`: Implement data sources, DTOs, and repository contracts.
   - `presentation`: Implement widgets, screens, and state management controllers.
6. **Register in Application Shell (`apps/mobile_app`)**:
   - Wire repository implementations and controllers into DI container in `mobile_app`.
