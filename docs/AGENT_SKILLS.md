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

## Skill 2: SOLID & Do's/Don'ts Code Refactoring Guidelines

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
4. **Context Safety**:
   - Never call `Navigator.of(context)` directly inside `MaterialApp.home` widget builder without a `Builder` context wrapper or key-based navigation.

---

## Skill 3: Agent Prompt Templates for Monorepo Operations

### Template 1: Generating a New Feature Block
```markdown
"Create a new feature '<feature_name>' in packages/features/<feature_name>/ divided into:
1. <feature_name>_domain: pure Dart entity, repository contract, and use case.
2. <feature_name>_data: DTO, remote data source, and repository implementation.
3. <feature_name>_presentation: state controller and UI screen.
Register all three packages in root pubspec.yaml workspace section and wire them in mobile_app service_locator."
```

### Template 2: Layer Violation Audit Prompt
```markdown
"Audit packages/features/<feature_name>/ for layer violations:
- Check if <feature_name>_domain contains flutter or network imports.
- Check if <feature_name>_presentation imports <feature_name>_data directly.
- Report any architectural breaches and output required refactoring diffs."
```

---

## Skill 4: Pre-commit Verification & Test Generator

Before marking any task as complete:
1. Generate unit tests for Domain Use Cases with mock repositories.
2. Generate unit tests for Data Repository Implementations with mock remote data sources.
3. Run static analysis across workspace: `flutter analyze` or `dart analyze`.
4. Run tests across workspace packages: `flutter test`.
