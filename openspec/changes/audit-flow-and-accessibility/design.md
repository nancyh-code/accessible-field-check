## Context

See `proposal.md` for motivation and `specs/audit-flow-and-accessibility/spec.md` for behavior.

The app already has `NavigationStack`, design-system components, Spanish/English strings, SwiftData `@Model` `Audit`/`AuditItem`, `AccessibilityCriterionCatalog`, and a concrete `AuditStore`. `AuditsView` always shows the empty state. `NewAuditPlaceholderView` does not persist. `AppDestination` is `.newAudit` only. `AccessibleFieldCheckApp` registers `.modelContainer(for: [Audit.self, AuditItem.self])`.

## Goals / Non-Goals

**Goals:**

- Wire existing persistence to four screens without a second domain layer.
- Keep navigation hierarchical and identifier-based.
- Make UI tests deterministic with the smallest launch-argument seam.

**Non-Goals:**

- Do not add `@Observable`, `ObservableObject`, Combine, coordinators, repositories, use cases, ViewModels, actors, or a DI container.
- Do not persist the criterion catalog or a localized default title.
- Do not add snapshot tests, CI, Fastlane, or third-party libraries.

## Decisions

### Navigation: identifier destinations on the existing stack

```swift
enum AppDestination: Hashable {
    case newAudit
    case checklist(UUID)
    case summary(UUID)
}
```

Use `Audit.identifier`, not SwiftData `persistentModelID`. No `TabView`. `AppRootView` keeps owning `NavigationStack(path:)`.

After a successful create, replace `.newAudit` with `.checklist(id)` so Back from the checklist returns to Audits, not the form. After Finish, replace `.checklist(id)` with `.summary(id)`. After reopen, replace `.summary(id)` with `.checklist(id)`. List taps append `.checklist` for drafts and `.summary` for completed audits.

**Alternative:** leave New Audit on the stack. Rejected because Back would return to an empty form.

**Alternative:** pass `@Model` instances in the path. Rejected because UUID identifiers stay `Hashable` and survive context refresh.

### State: `@Query` on Audits, `@State` on forms, local `AuditStore`

- `AuditsView`: `@Query(sort: \Audit.updatedAt, order: .reverse)` and the existing `@Binding` path. `@Query` is justified because the list must stay live after create/complete/reopen.
- `NewAuditView`: `@State` title (and a validation flag). `@Environment(\.modelContext)` plus `AuditStore(modelContext:)`.
- Checklist and summary: take the audit UUID, resolve the `Audit` from the environment `ModelContext` / `AuditStore`, and keep expansion/confirmation in `@State`.

Do not add `@Observable`. Shared mutation is SwiftData; presentation state is local.

**Alternative:** a session `AuditFlowModel`. Rejected because it duplicates `AuditStore` and the navigation path.

### Persistence boundary: reuse `AuditStore` as-is

Views call `createDraft`, `updateResult`, `updateNote`, `complete`, and `reopen`. Title passed to `createDraft` is `trimmingCharacters(in: .whitespacesAndNewlines)` after validation; do not substitute a localized string. Production omits `now:` (defaults to `.now`). Do not add store methods for progress or summary counts.

### Presentation helpers, not UI models

Add a small pure helper (for example `AuditReviewProgress`) that derives reviewed count and pass / needsAttention / notApplicable / notReviewed counts from `[AuditResult]`. Reviewed means `result != .notReviewed`. This is not a persisted type and not a DTO mapper.

Checklist rows join `audit.items` to `AccessibilityCriterionCatalog.all` by `criterionID` and display in catalog `sortOrder`, grouped by `CriterionCategory`.

### Checklist interaction: one screen, inline detail

Use a `List` with one section per category. Each row shows localized title (`criterion.<id>.title`), guidance (`criterion.<id>.guidance`), and current result. Notes use an inline expandable field on the same screen (`DisclosureGroup` or equivalent). Do not push a per-criterion destination.

Result control: four wrapping buttons or a vertical stack of `Label`s (icon + text), minimum 44 pt, semantic colors from `AFCTokens`. Do not use `Picker(.segmented)` as the only control; it fails at accessibility text sizes.

### Design system

Reuse `AFCTokens`, `AFCPrimaryButton`, `AFCStatusBadge`, `AFCEmptyState`. Extend `AFCStatus` with `notReviewed` (icon + localized text + secondary semantic color) so checklist results and summary/list status chips share one non-color-only representation. That extension is justified by accessibility duplication, not by speculative component growth.

Audit status (`draft` / `completed`) uses localized text on list and summary rows; it is not an `AFCStatus` value.

### Completion confirmation

If `notReviewed` count is greater than zero, show a `confirmationDialog` that states unreviewed items remain, then call `AuditStore.complete`. If every item is reviewed, complete immediately. Never block Finish.

### UI-test isolation: one launch argument

Launch argument: `-ui-testing-empty-store`.

When present, `AccessibleFieldCheckApp` builds an in-memory `ModelConfiguration(isStoredInMemoryOnly: true)` `ModelContainer` for `Audit` and `AuditItem`. When absent, keep the current on-disk container. Do not add an environment framework.

Update/replace `AuditsSmokeUITests` so every UI test passes that argument. Keep `audits.screen`, `audits.emptyState`, `audits.newAuditButton`, and `newAudit.screen`. Add identifiers only for the happy path and validation: title field, create, checklist, finish, summary, and two criterion result controls.

### Localization

Spanish source, English secondary. Add flow keys under `audit.*` / `navigation.*` / `designSystem.status.notReviewed`. Reuse criterion and category keys. Stop using `audit.new.placeholder`. Do not add `audit.draft.defaultTitle`. Title-field placeholder is presentation-only.

### Testing

Swift Testing: `AuditReviewProgress` only. Do not retest `AuditStore`.

XCTest UI:

1. Empty-store happy path: create titled audit → checklist → two results (including `needsAttention`) → one note → Finish → summary shows that item → back to Audits shows the row.
2. Empty/whitespace title: create does not add a row; error is present.

No snapshots. No new UI-test target.

### Expected commits during apply

1. `chore: plan audit flow and accessibility`
2. `feat: add audit creation and list flow`
3. `feat: add accessibility review workflow`
4. `test: verify accessible audit flow`
5. `chore: archive audit flow and accessibility`

## Risks / Trade-offs

- **[Risk] `@Query` plus path replacement can briefly miss a just-inserted audit.** → Mitigation: navigate with the UUID returned by `createDraft`; resolve the audit in the destination from `ModelContext`.
- **[Risk] Completing with `notReviewed` items looks finished.** → Mitigation: confirmation copy plus summary counts; already allowed by persistence spec.
- **[Trade-off] In-memory UI-test store does not prove on-disk launch.** → Accepted; unit tests already cover persistence round-trip.
- **[Trade-off] Extending `AFCStatus` couples design-system badges to four results.** → Accepted to avoid a second color-only-prone status view.

## Migration Plan

Greenfield UI on existing schema v1. Rollback is reverting the implementation commits. `NewAuditPlaceholderView` is deleted; no data migration.

## Open Questions

None. Navigation replacement, `@Query`, launch-argument isolation, inline checklist, and unreviewed completion are decided above.
