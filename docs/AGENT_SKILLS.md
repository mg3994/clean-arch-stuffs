# AI Agent Skills & System Directives for Modular Dart Monorepo

When working within this Dart Monorepo, AI agents (LLMs, coding assistants) must adhere strictly to these operational guidelines, skills, and constraints.

---

## Skill 1: Strict Layer Isolation Enforcer

### Objective
Ensure code is placed in the correct package layer and prevent illegal cross-layer imports.

### Verification Matrix
- **`*_domain` packages**:
  - Must NEVER contain `import 'package:flutter/...'`.
  - Must NEVER contain imports from `*_data` or `*_presentation`.
  - Must NEVER contain imports from HTTP libraries (`dio`, `http`).
- **`*_presentation` packages**:
  - Must NEVER contain `import 'package:<feature>_data/...'`.
  - Interfaces and state classes must interact solely with `UseCase` objects or Domain `Entities`.
- **`*_data` packages**:
  - Must implement repository interfaces defined in `*_domain`.
  - DTOs (Data Transfer Objects) must have mapper methods (`toEntity()`, `fromEntity()`) to keep domain objects decoupled from API schemas.

---

## Skill 2: SOLID Code Refactoring Guidelines

### Checklist for Agents Generating Code
1. **Single Responsibility (SRP)**:
   - Create focused classes. A UseCase should perform a single action (e.g., `GetUserProfileUseCase`).
   - Mappers convert DTOs to Entities in a separate mapper extension or class.
2. **Open/Closed Principle (OCP)**:
   - Repositories must be abstract contracts (`abstract class AuthRepository`).
   - Mocking in unit tests must be done using repository abstractions without changing production domain code.
3. **Dependency Inversion (DIP)**:
   - Never instantiate concrete repositories directly inside presentation controllers or widgets.
   - Always inject repository abstractions via constructor parameters.

---

## Skill 3: Workspace Dependency Resolver Skill

When adding new imports or dependencies:
1. Always verify if the target package exists in `packages/` or `pubspec.yaml` workspace list.
2. Add workspace members to package `pubspec.yaml` under `dependencies:` with empty version tags (`core_domain:`), relying on `resolution: workspace`.
3. Run `dart pub get` at the root directory to refresh resolution across all packages simultaneously.

---

## Skill 4: Pre-commit Verification & Test Generator

Before marking any task as complete:
1. Generate unit tests for Domain Use Cases with mock repositories.
2. Generate unit tests for Data Repository Implementations with mock remote data sources.
3. Run static analysis across workspace: `flutter analyze` or `dart analyze`.
4. Run tests across workspace packages: `flutter test`.
