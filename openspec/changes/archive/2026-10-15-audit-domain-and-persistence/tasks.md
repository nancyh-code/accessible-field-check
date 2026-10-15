## 1. Domain model and criterion catalog

- [x] 1.1 Add `AuditStatus`, `AuditResult`, and `CriterionCategory` as string-backed enums and verify they expose the cases required by the spec.
- [x] 1.2 Add `AccessibilityCriterion` and `AccessibilityCriterionCatalog.all` with the 12 stable IDs, categories, sort order 1…12, and title/guidance keys from `design.md`, and verify IDs are unique and match the spec set.
- [x] 1.3 Add Spanish source and English String Catalog entries for each `criterion.<id>.title` / `.guidance` and each `criterionCategory.<case>`, and verify no `audit.draft.defaultTitle` key is added and no criterion identity is stored as translated text.
- [x] 1.4 Confirm `AuditsView` and `NewAuditPlaceholderView` are unchanged so the New Audit CTA still does not create an audit.

## 2. SwiftData persistence

- [x] 2.1 Add SwiftData `@Model` types `Audit` and `AuditItem` with the fields and cascade relationship in `design.md`, and verify a `ModelContainer` can be created for both.
- [x] 2.2 Add `AuditStore.createDraft(title:now: Date = .now)` that persists the caller-supplied title and one `notReviewed` item per catalog criterion with no duplicate `criterionID`s, and verify it does not write a localized default title.
- [x] 2.3 Implement result update, note add/edit/remove, complete, reopen, and fetch-by-`updatedAt` descending on `AuditStore`, with `now: Date = .now` on mutations, and verify complete/reopen do not rewrite or drop items.
- [x] 2.4 Register `.modelContainer(for: [Audit.self, AuditItem.self])` on the app scene without changing navigation or landing copy, and verify the app still builds.

## 3. Focused domain and persistence tests

- [x] 3.1 Add Swift Testing coverage for catalog count, unique IDs, required ID set, and localization keys (not display strings), and verify those tests pass.
- [x] 3.2 Add in-memory SwiftData tests for draft initialization with a supplied title, default `notReviewed`, empty notes, and no duplicate criteria, and verify they pass.
- [x] 3.3 Add tests for result updates, note add/edit/remove, completion with unfinished items, and reopen preserving results, using explicit `Date` values where timestamps matter, and verify they pass.
- [x] 3.4 Add a persistence round-trip test (new `ModelContext` on the same in-memory store) and a fetch-order test that uses distinct supplied `updatedAt` values, and verify they pass.
- [x] 3.5 Run the focused unit-test suite and a generic iOS Simulator build, and verify no new UI tests, GitHub Actions, or Fastlane files were added.
