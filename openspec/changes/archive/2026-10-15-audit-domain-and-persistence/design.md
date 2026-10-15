## Context

See `proposal.md` for motivation and `specs/audit-domain-and-persistence/spec.md` for behavior.

The app already has a SwiftUI shell, `NavigationStack`, design system, Spanish/English String Catalog, and tests. Audits landing is always empty and New Audit is a non-persisting placeholder. This change adds domain + SwiftData only; it does not replace that placeholder.

## Goals / Non-Goals

**Goals:**

- Make draft create, item update, complete, reopen, and newest-first fetch testable without checklist UI.
- Keep criterion identity in stable IDs and localization keys.
- Register persistence on the app so the next workflow change can fetch immediately.

**Non-Goals:**

- Do not add a DTO/mapper layer, repository protocol, use cases, DI container, Clock service, or timestamp protocol.
- Do not change Audits empty-state copy, navigation destinations, or the New Audit placeholder.
- Do not add UI tests, scoring, or schema migration tooling.

## Decisions

### Domain / persistence boundary: option A for stored types

**Choice:** SwiftData `@Model` types *are* the persisted domain (`Audit`, `AuditItem`). The criterion catalog stays an in-code value-type list referenced by `criterionID` strings. Status and result are small `String`-raw enums stored on the models.

**Why A:** This project has one local store, no backend, and tests already need a `ModelContainer` for round-trips. A second struct layer would duplicate fields without a consumer.

**Alternative B (rejected):** Separate `Audit` value types plus `AuditRecord` models and mapping. Safer if SwiftData leaks into UI, but this change has no checklist UI and would add files the next change would have to keep in sync.

Catalog types (`AccessibilityCriterion`, `CriterionCategory`) are not `@Model` because they are not persisted.

### Persistence operations: one concrete `AuditStore`

`AuditStore` is a struct wrapping `ModelContext` (not a protocol):

- `createDraft(title:now: Date = .now) throws -> Audit` — UUID, caller-supplied title, `createdAt`/`updatedAt` = `now`, status `draft`, one `AuditItem` per catalog criterion in `sortOrder`
- `updateResult(item:result:now: Date = .now)`
- `updateNote(item:note:now: Date = .now)` — `nil` or empty removes the note
- `complete(_:now: Date = .now)` / `reopen(_:now: Date = .now)`
- `fetchAudits() throws -> [Audit]` — `updatedAt` descending

No `actor`. Callers are `@MainActor` (app already uses MainActor isolation). Tests construct an in-memory container and a store, and pass explicit `Date` values when they need deterministic `updatedAt`. Do not add a Clock type.

**Title rule:** localized strings belong to presentation; `Audit.title` is user-authored data; criterion IDs and category IDs are stable domain identity. A future UI may show a localized placeholder suggestion, but that string is not persisted unless the user explicitly chooses it as the title.

**Alternative:** static methods on `Audit`. Rejected because fetch/create span context + catalog and read more clearly as store operations.

### Criterion catalog

`AccessibilityCriterionCatalog.all` is a static array of 12 value types, IDs as in the spec. `sortOrder` is 1…12 in that same order.

| ID | Category | Title key |
| --- | --- | --- |
| dynamicType | textAndContent | criterion.dynamicType.title |
| contentScaling | textAndContent | criterion.contentScaling.title |
| colorContrast | textAndContent | criterion.colorContrast.title |
| colorIndependentMeaning | textAndContent | criterion.colorIndependentMeaning.title |
| voiceOverLabels | navigation | criterion.voiceOverLabels.title |
| focusOrder | navigation | criterion.focusOrder.title |
| modalAccessibility | navigation | criterion.modalAccessibility.title |
| touchTargetSize | interaction | criterion.touchTargetSize.title |
| formLabels | interaction | criterion.formLabels.title |
| clearButtonLabels | interaction | criterion.clearButtonLabels.title |
| reduceMotion | interaction | criterion.reduceMotion.title |
| errorIdentification | feedbackAndErrors | criterion.errorIdentification.title |

Guidance keys: `criterion.<id>.guidance`. Category keys: `criterionCategory.<case>`. Add Spanish source + English to `Localizable.xcstrings`. Do not store WCAG numbers. Do not add `audit.draft.defaultTitle`.

### SwiftData shape

```swift
@Model final class Audit {
    var identifier: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var statusRaw: String
    @Relationship(deleteRule: .cascade, inverse: \AuditItem.audit)
    var items: [AuditItem]
}

@Model final class AuditItem {
    var identifier: UUID
    var criterionID: String
    var resultRaw: String
    var note: String?
    var updatedAt: Date
    var audit: Audit?
}
```

Use `identifier` rather than colliding with SwiftData’s `id` if needed; expose `status` / `result` via enum computed properties. Uniqueness of `criterionID` per audit is enforced by `createDraft`, not a database unique index.

Schema v1. No migration. App: `WindowGroup { AppRootView() }.modelContainer(for: [Audit.self, AuditItem.self])`. Tests: in-memory `ModelConfiguration(isStoredInMemoryOnly: true)`.

Timestamps: create sets both dates equal to `now`; item result/note updates set `item.updatedAt` and `audit.updatedAt` to `now`; complete/reopen set `audit.updatedAt` to `now` only. Production call sites omit `now` (defaults to `.now`). Tests pass fixed dates.

Completion does not validate remaining `notReviewed` items and does not rewrite them.

### UI boundary

Do not edit `AuditsView` or `NewAuditPlaceholderView`. The placeholder still must not create an audit.

### Testing

Swift Testing only. Catalog tests need no container. Store tests use in-memory SwiftData and explicit `Date` arguments for ordering and round-trip assertions. No XCTest UI additions.

### Expected commits during apply

1. `chore: plan audit domain and persistence`
2. `feat: add audit domain model`
3. `feat: add SwiftData audit persistence`
4. `test: verify audit domain persistence`
5. `chore: archive audit domain and persistence`

## Risks / Trade-offs

- **[Risk] `@Model` as domain couples UI later to SwiftData.** → Mitigation: accepted for V1; revisit only if a backend appears.
- **[Risk] ModelContainer is registered but unused by current screens.** → Mitigation: documented seam; do not fake list data on Audits.
- **[Risk] Completing with `notReviewed` items looks like a finished review.** → Mitigation: spec allows it; the later UI can show incomplete state.
- **[Trade-off] No unique index on `(audit, criterionID)`.** → `createDraft` is the only item factory in this change.

## Migration Plan

Greenfield schema. Rollback is reverting the implementation commits. The later workflow change should call `AuditStore` and replace the New Audit placeholder; it should not redesign the catalog IDs.

## Open Questions

None. Boundary, completion, catalog IDs, and UI non-wiring are decided above.
