## Why

The app has a navigation shell and design system, but no audit domain or local storage. The next user-facing workflow cannot create, update, or list reviews until a small, testable domain and SwiftData persistence layer exist.

## What Changes

- Add a minimal audit domain: `Audit`, `AuditStatus`, `AccessibilityCriterion`, `CriterionCategory`, `AuditItem`, and `AuditResult`.
- Add a deterministic built-in catalog of 12 mobile-app accessibility criteria, referenced by stable IDs and localization keys (not translated stored text).
- Persist audits, items, results, optional notes, timestamps, and status with SwiftData. Do not persist the criterion catalog.
- Support `createDraft(title:)` (catalog-populated items, user-authored title), result and note updates, completion, reopen, and fetch by `updatedAt` descending. Do not persist a localized default title.
- Add focused Swift Testing coverage with an in-memory `ModelContainer`.
- Register a SwiftData container on the app so persistence is available. Do not replace the New Audit placeholder or add checklist UI.

Out of scope: checklist/summary screens, photos, export, networking, login, sync, AI, OCR, maps, PDF, analytics, GitHub Actions, Fastlane, WCAG certification, legal scoring, percentages, and a recommendations engine.

## Capabilities

### New Capabilities

- `audit-domain-and-persistence`: Audit domain model, built-in criterion catalog, SwiftData persistence, integrity rules, and focused domain/persistence tests.

### Modified Capabilities

- None. The existing `project-and-design-system-foundation` requirements stay: the New Audit CTA still opens a non-persisting placeholder, and this change does not add checklist UI.

## Impact

- New domain/catalog and SwiftData model files; a small `AuditStore` (or equivalent) for create/update/complete/fetch.
- `AccessibleFieldCheckApp` registers a `ModelContainer` without changing Audits landing copy or navigation destinations.
- String Catalog keys for criterion titles, categories, and guidance only. Do not add `audit.draft.defaultTitle`. Localized presentation strings stay out of persisted `Audit.title`.
- `AccessibleFieldCheckTests` gains in-memory SwiftData tests. No new UI tests, CI, or packages.
