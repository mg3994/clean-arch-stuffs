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
    │   ├── core_data/
    │   └── core_ui/
    ├── shared/                  # Independent shared utility packages
    │   └── logger_service/
    └── features/                # Domain-Driven Feature packages
        ├── auth/
        │   ├── auth_domain/
        │   ├── auth_data/
        │   └── auth_presentation/
        └── blog/
            ├── blog_domain/
            ├── blog_data/
            └── blog_presentation/
```

---

## 2. Monorepo Do's and Don'ts

| Category | DO ✅ | DON'T ❌ |
| :--- | :--- | :--- |
| **Workspace Setup** | **DO** register every package path in the root `pubspec.yaml` `workspace:` section. | **DON'T** use legacy relative `path:` dependencies between packages inside the same workspace. |
| **Dependencies** | **DO** set `resolution: workspace` in all workspace member packages. | **DON'T** specify version constraints (`^1.0.0`) for internal workspace dependencies. |
| **Imports** | **DO** import workspace packages using `package:<pkg_name>/<file>.dart`. | **DON'T** use relative cross-package imports (e.g. `import '../../core_domain/lib/...'`). |
| **Cleanliness** | **DO** commit `.gitignore` excluding `.dart_tool/`, `.pub/`, and `build/`. | **DON'T** commit generated build artifacts or local cache folders to git tracking. |
| **Task Execution**| **DO** run `dart pub get` from the root directory to resolve dependencies across all packages at once. | **DON'T** run `dart pub get` manually inside 15 different directories sequentially. |

---

## 3. Native Workspaces vs. Melos Comparison

| Feature | Native Dart Workspaces (Dart 3.5+) | Melos |
| :--- | :--- | :--- |
| **Dependency Resolution** | Native single lockfile (`pubspec.lock` at root) | Synthesizes symlinks or path overrides |
| **Setup Overhead** | Zero extra tools needed (built into Dart/Flutter SDK) | Requires global pub install of `melos` |
| **Script Automation** | Run standard `dart` / `flutter` CLI commands | Custom `melos.yaml` script runners |
| **IDE Support** | Native out-of-the-box support in VS Code & Android Studio | Requires Melos extension/plugin |
| **Best Choice For** | Modern Flutter/Dart monorepos (Dart 3.5+) | Legacy monorepos or repos needing custom bash scripts |

---

## 4. CI/CD Pipeline Guidelines for Workspaces

In GitHub Actions, GitLab CI, or Codemagic:

```yaml
name: Monorepo CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Resolve Workspace Dependencies
        run: dart pub get

      - name: Run Workspace Static Analysis
        run: flutter analyze

      - name: Run All Workspace Unit Tests
        run: |
          find packages apps -name "*_test.dart" | xargs flutter test
```

---

## 5. How to Add a New Feature Module (Step-by-Step)

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
