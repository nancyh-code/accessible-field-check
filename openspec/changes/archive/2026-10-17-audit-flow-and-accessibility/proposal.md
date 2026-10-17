## Why

The app can persist audits and a 12-criterion catalog, but the Audits screen is still an empty shell and New Audit is still a non-persisting placeholder. The V1 product is a structured review workflow, and that workflow cannot be demonstrated or accessibility-tested until the existing `AuditStore` is wired to real screens.

## What Changes

- Replace the permanent empty Audits landing with a persisted list (newest `updatedAt` first) while keeping the existing empty state when no audits exist.
- Replace `NewAuditPlaceholderView` with a real `NewAuditView`: user-authored title, fixed Mobile App context, validation, and `AuditStore.createDraft` then navigate to the checklist.
- Add `AuditChecklistView`: 12 items in catalog order, grouped by category, result + optional note, descriptive progress, and Finish even if items remain `notReviewed`.
- Add `AuditSummaryView`: descriptive counts, Needs Attention with notes, and reopen/edit via `AuditStore.reopen`.
- Keep a single `NavigationStack`. Draft rows open the checklist; completed rows open the summary. No `TabView`.
- Verify the workflow for Dynamic Type, VoiceOver, 44 pt targets, labeled fields, icon+text+semantic color (never color alone), dark mode, and iPhone/iPad landscape.
- Add a deterministic empty-store UI-test launch path and a small end-to-end happy-path UI test, plus empty-title validation.

Out of scope: photos, export, PDF, OCR, AI, networking, backend, login, sync, analytics, maps, search, filtering, custom criteria, templates, web/physical-space audits, WCAG certification, legal compliance, scoring, percentages, charts, GitHub Actions, and Fastlane.

## Capabilities

### New Capabilities

- `audit-flow-and-accessibility`: User-facing audit list, creation, checklist, summary, completion/reopen navigation, workflow accessibility, and UI-test isolation for the V1 review flow.

### Modified Capabilities

- `project-and-design-system-foundation`: The New Audit action SHALL open a real creation form instead of a non-persisting placeholder. The empty Audits copy remains only when no audits exist.

## Impact

- App UI: rewrite `AuditsView`; replace `NewAuditPlaceholderView` with `NewAuditView`; add `AuditChecklistView` and `AuditSummaryView`; expand `AppDestination`; register an in-memory container when a UI-test launch argument is present.
- Reuse `Audit`, `AuditItem`, `AuditStore`, and `AccessibilityCriterionCatalog`. Do not add parallel UI domain models.
- String Catalog: add only flow strings (`audit.*`, `navigation.*`, `designSystem.status.notReviewed` if needed). Reuse existing criterion keys. Remove or stop using `audit.new.placeholder`.
- Design system: reuse `AFCTokens`, `AFCPrimaryButton`, `AFCStatusBadge`, `AFCEmptyState`. Extend the status badge for `notReviewed` only if two screens need it.
- Tests: extend/replace the XCTest smoke test with an empty-store happy path and one validation case. Add Swift Testing only for non-trivial presentation helpers. No new packages, CI, or Fastlane.
