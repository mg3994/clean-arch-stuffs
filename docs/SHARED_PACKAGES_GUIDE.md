# Monorepo Strategy for External & Shared Packages

## Overview
In an enterprise monorepo, applications often rely on utility libraries, network clients, logging infrastructures, design tokens, and shared contracts.

This document outlines the **Monorepo Approach for Shared Packages**—explaining how to structure, version, consume, and distribute shared libraries without introducing tight coupling or dependency cycles.

---

## 1. Categorization of Shared Packages

In this monorepo, shared packages are organized into three distinct tiers:

```
packages/
  ├── core/               # App-wide Clean Architecture core layers (core_domain, core_data, core_ui)
  └── shared/             # Independent, utility/service shared packages
      ├── logger_service/ # Logging abstraction & loggers
      ├── storage_client/ # Keychain / Local storage wrapper
      └── analytics_engine/# Analytics event tracking engine
```

### A. Core Packages (`packages/core/`)
- **Purpose**: Foundational contracts for Clean Architecture (base UseCases, Result/Failure types, Network Clients, Design Tokens).
- **Scope**: Highly tied to the app's Clean Architecture conventions.

### B. Shared Utility Packages (`packages/shared/`)
- **Purpose**: Pure infrastructure or domain-agnostic tools (e.g. `logger_service`, `storage_client`, `crypto_utils`).
- **Scope**: Zero knowledge of feature business logic or Clean Architecture entities. Designed to be completely pluggable.

---

## 2. Shared Packages Do's and Don'ts

| Category | DO ✅ | DON'T ❌ |
| :--- | :--- | :--- |
| **Coupling** | **DO** keep shared utility packages domain-agnostic and feature-agnostic. | **DON'T** import feature packages (`packages/features/*`) or app shells into `packages/shared/*`. |
| **Dependencies** | **DO** wrap third-party libraries (e.g. `dio`, `logger`, `hive`) inside shared package abstractions. | **DON'T** leak raw third-party classes across the entire codebase; expose clean interface contracts. |
| **Exports** | **DO** export public interfaces via `lib/<pkg_name>.dart`. Keep internals in `lib/src/`. | **DON'T** allow consumers to directly import private files from `lib/src/`. |
| **Cycles** | **DO** keep shared package dependency trees acyclic and flat. | **DON'T** create circular dependencies between `shared` packages (e.g. `pkg_a` depending on `pkg_b` and vice-versa). |

---

## 3. Monorepo vs. External Pub Publishing Strategy

Shared packages can be maintained in two modes:

### Mode 1: In-Monorepo Workspace Packages (Recommended Default)
- **Location**: `packages/shared/<package_name>`
- **Declaration in Member Pubspec**:
  ```yaml
  name: core_data
  environment:
    sdk: '>=3.5.0 <4.0.0'
  resolution: workspace

  dependencies:
    logger_service:
  ```
- **Benefits**:
  - Instant hot-reloading across packages.
  - Zero publishing overhead during daily feature development.
  - Single atomic commit updates both the shared library and its consumers.

### Mode 2: External Pub Packages (Published to Private or Public Pub)
- **Scenario**: When a shared package (e.g., `company_logger` or `design_system`) is consumed by external repositories outside this monorepo.
- **Consumption in Monorepo**:
  Option A: Git dependency or Hosted Pub server dependency in `pubspec.yaml`:
  ```yaml
  dependencies:
    company_logger:
      hosted: https://pub.mycompany.com
      version: ^2.1.0
  ```
  Option B: Local path override during local development:
  ```yaml
  dependency_overrides:
    company_logger:
      path: ../../external_repos/company_logger
  ```

---

## 4. Versioning & Release Workflow

When shared packages mature and require standalone versioning:
1. Follow **Semantic Versioning (SemVer)** (`MAJOR.MINOR.PATCH`).
2. Maintain a `CHANGELOG.md` in each `packages/shared/<pkg>` folder.
3. Automated CI pipelines can detect changes under `packages/shared/<pkg>` and trigger pub dry-runs or automated tag releases.
