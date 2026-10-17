## 1. Audits list and New Audit

- [x] 1.1 Expand `AppDestination` with `checklist(UUID)` and `summary(UUID)`, register those destinations on the existing `NavigationStack`, delete `NewAuditPlaceholderView`, and verify the app still builds with no `TabView`.
- [x] 1.2 Replace the always-empty `AuditsView` with `@Query` sorted by `updatedAt` descending, keep `AFCEmptyState` when the query is empty, show title/status/progress/date on each row, route draft taps to checklist and completed taps to summary, and verify empty vs list states.
- [x] 1.3 Add a New Audit action on the list (toolbar or equivalent) in addition to the empty-state CTA, reuse `audits.newAuditButton` where it remains the primary create action, and verify both empty and non-empty Audits can open New Audit.
- [x] 1.4 Replace the placeholder with `NewAuditView`: labeled title field, fixed Mobile App context, create action, `newAudit.screen` identifier, and verify whitespace-only titles show an announced error and do not call `createDraft`.
- [x] 1.5 On a valid trimmed title, call `AuditStore.createDraft(title:)`, replace `.newAudit` on the path with `.checklist(id)`, persist that exact title, and verify no localized default title is written.
- [x] 1.6 Add Spanish source and English strings required by the list and form, stop using `audit.new.placeholder`, and verify no `audit.draft.defaultTitle` key is added.

## 2. Checklist and summary

- [x] 2.1 Add `AuditChecklistView` that joins items to `AccessibilityCriterionCatalog` by `criterionID`, groups by category in catalog `sortOrder`, shows localized title and guidance, and verify all 12 criteria appear once.
- [x] 2.2 Add a wrapping four-option result control (icon + text + semantic color, 44 pt minimum, not a compact segmented picker) wired to `AuditStore.updateResult`, extend `AFCStatus` with `notReviewed` if needed, and verify a result change persists and is not color-only.
- [x] 2.3 Add inline expandable note editing on the same screen via `AuditStore.updateNote`, and verify add/edit/remove without a per-criterion destination.
- [x] 2.4 Show “N of 12 reviewed” using `AuditReviewProgress`, add Finish with a confirmation dialog only when unreviewed items remain, call `AuditStore.complete`, replace the path with `.summary(id)`, and verify completion keeps `notReviewed` items.
- [x] 2.5 Add `AuditSummaryView` with title, status, four counts, and a Needs Attention list that includes notes, plus reopen via `AuditStore.reopen` that replaces the path with `.checklist(id)`, and verify results and notes are preserved.
- [x] 2.6 Add `AuditReviewProgress` pure helpers and Swift Testing for reviewed count and result tallies, and verify those tests pass without duplicating `AuditStore` coverage.

## 3. Accessibility and UI tests

- [ ] 3.1 Apply Dynamic Type, VoiceOver labels, 44 pt targets, labeled title field, announced validation, navigation titles, dark mode, and iPhone/iPad landscape-safe layout with no clipping fixed heights, and verify the four workflow screens remain readable at accessibility extra-large text.
- [ ] 3.2 Switch `AccessibleFieldCheckApp` to an in-memory empty `ModelContainer` when launch argument `-ui-testing-empty-store` is present, add identifiers needed for the happy path and validation, and verify production launch still uses the on-disk container.
- [ ] 3.3 Add an XCTest UI happy path that launches with the empty-store argument, creates a titled audit, sets two results including `needsAttention`, adds one note, finishes, asserts the summary, and returns to Audits showing the persisted row.
- [ ] 3.4 Add an XCTest UI case that launches with the empty-store argument, submits an empty title, and verify no audit row appears and the validation error exists.
- [ ] 3.5 Replace placeholder smoke assertions, run the unit-test target plus UI tests and a generic iOS Simulator build, and verify no GitHub Actions or Fastlane files were added.
