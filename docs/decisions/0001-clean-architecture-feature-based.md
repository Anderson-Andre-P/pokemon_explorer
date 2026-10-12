# 0001. Clean Architecture, feature-based

- **Date:** 10/11/2026
- **Status:** Accepted

## Context

Pokémon Explorer is a portfolio project: reviewers read the code to judge how it is organized. It has ~10 features that share one core concept (a Pokémon) and combine remote data, a local cache and user data. The structure must make the data flow obvious and keep business rules testable without Flutter.

## Decision

- Three layers per feature: **presentation → domain ← data**. Domain is pure Dart; data implements domain repository interfaces; presentation depends only on domain.
- Organize **by feature** first (`lib/features/<feature>/<layer>`), not by layer. A feature carries only the layers it needs.
- `features/pokemon` is the shared Pokémon core; other features may use its **domain** only. No feature imports another feature's data or presentation. Shared UI and infrastructure live in `lib/core/`, which never imports features. `lib/app/` is the composition root.
- Mandated abstractions: repository interfaces, data source interfaces, use cases. Nothing else without a testing or substitution reason.

## Alternatives

- **Layer-first folders** (`lib/data`, `lib/domain`, `lib/ui`) — simpler at first, but a feature's code scatters across the tree and boundaries blur.
- **No domain layer** (Bloc → repository) — less code, but business rules (team limits, comparison) would live in Blocs or repositories and be harder to test in isolation.

## Consequences

- More files per feature; each has one clear job.
- Boundaries are a convention until something checks them automatically.
