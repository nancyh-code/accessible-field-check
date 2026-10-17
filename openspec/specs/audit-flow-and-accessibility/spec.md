# audit-flow-and-accessibility Specification

## Purpose
Defines the V1 user-facing accessibility-review workflow: persisted Audits list, New Audit creation, criterion checklist, descriptive summary, completion and reopen, workflow accessibility, and isolated UI tests.

## Requirements

### Requirement: Audits shows empty state or a newest-first list
When no audits exist, the Audits screen SHALL show the existing empty state and a New Audit action. When audits exist, the screen SHALL list them ordered by updatedAt descending. Each row SHALL show the audit title, status, a descriptive reviewed-item progress summary, and the updated date. Activating a draft audit SHALL open the checklist. Activating a completed audit SHALL open the summary. A New Audit action SHALL remain available when the list is shown. The screen SHALL NOT add search, filter, or sort controls.

#### Scenario: Empty store shows empty state
- **WHEN** the user opens Audits and no audits exist
- **THEN** the empty state and New Audit action are shown

#### Scenario: List is newest first
- **WHEN** two audits exist and one has a later updatedAt
- **THEN** that audit appears before the other, and each row shows title, status, progress, and updated date

#### Scenario: Draft opens checklist
- **WHEN** the user activates a draft audit in the list
- **THEN** the checklist for that audit is shown

#### Scenario: Completed opens summary
- **WHEN** the user activates a completed audit in the list
- **THEN** the summary for that audit is shown

### Requirement: New Audit requires a user-authored title
The New Audit screen SHALL present a labeled title field, a fixed Mobile App context that is not a platform selector, and a create action. The title SHALL be user-authored data. A title that is empty or whitespace-only SHALL be invalid: the system SHALL announce a validation error and SHALL NOT persist an audit or a localized default title. A localized placeholder on the title field is presentation-only. A valid title SHALL create a draft audit populated from the built-in catalog and SHALL open that audit’s checklist. The screen SHALL NOT collect client, URL, version, photos, or custom criteria.

#### Scenario: Whitespace title is rejected
- **WHEN** the user activates create with an empty or whitespace-only title
- **THEN** no audit is persisted and a validation error is announced

#### Scenario: Valid title opens the checklist
- **WHEN** the user submits a non-whitespace title
- **THEN** a draft audit with that exact title is persisted and the checklist for that audit is shown

### Requirement: Checklist presents every catalog criterion
The checklist SHALL show exactly one row per catalog criterion, in catalog sort order, grouped by category. Each row SHALL show the localized criterion title, short localized guidance, and the current result. Result options SHALL be not reviewed, pass, needs attention, and not applicable, each with icon, localized text, and semantic color. Meaning SHALL NOT depend on color alone. The user SHALL be able to add, edit, or remove an optional note without leaving the checklist. Changing a result or note SHALL persist immediately.

#### Scenario: Catalog order and grouping
- **WHEN** the checklist is shown
- **THEN** it contains all 12 criteria grouped by category in deterministic catalog order

#### Scenario: Result is not color-only
- **WHEN** a criterion result is set to pass
- **THEN** the row shows that result with icon, text, and semantic color, and a later read of the audit returns pass for that item

#### Scenario: Note can be added
- **WHEN** the user adds a note on a criterion
- **THEN** later reads of that item include the note

### Requirement: Progress is reviewed-count only
The checklist SHALL show descriptive progress of the form “N of 12 reviewed”, where reviewed means the result is not notReviewed. The system SHALL NOT show percentages, weighted scores, grades, or pass thresholds.

#### Scenario: Progress counts reviewed items
- **WHEN** 7 of 12 items have a result other than notReviewed
- **THEN** the checklist progress indicates that 7 of 12 items are reviewed

### Requirement: Finish is allowed with unreviewed items
The checklist SHALL offer a Finish Audit action. Completing an audit SHALL be allowed even if some items remain notReviewed. If unreviewed items remain, the system SHALL communicate that clearly before completing. Completion SHALL NOT discard or rewrite items. After completion the summary for that audit SHALL be shown.

#### Scenario: Finish with unreviewed items
- **WHEN** the user finishes an audit that still has at least one notReviewed item
- **THEN** the system communicates the unreviewed remainder, the audit status becomes completed, those items remain notReviewed, and the summary is shown

### Requirement: Summary is descriptive and can reopen
The summary SHALL show the audit title, status, total criteria, and counts for pass, needs attention, not applicable, and not reviewed. A Needs Attention section SHALL list each criterion whose result is needsAttention and SHALL show its note when present. The summary SHALL NOT show a compliance percentage, accessibility score, legal result, or WCAG conformance level. A completed audit SHALL offer a reopen action that restores draft status, preserves results and notes, and opens the checklist.

#### Scenario: Counts and needs-attention notes
- **WHEN** a completed audit has mixed results including at least one needsAttention item with a note
- **THEN** the summary counts match those results and the Needs Attention section lists that criterion with its note

#### Scenario: Reopen preserves results
- **WHEN** the user reopens a completed audit
- **THEN** its status is draft, previously stored results and notes are unchanged, and the checklist is shown

### Requirement: Workflow screens meet the accessibility contract
Audits, New Audit, checklist, and summary SHALL support Dynamic Type, VoiceOver, logical focus and reading order, a practical 44 by 44 point minimum touch target, semantic color plus icon and text for result/status, labeled form fields, announced validation errors, navigation titles, dark mode, and iPhone and iPad landscape. They SHALL NOT clip accessibility text with fixed heights. Result controls SHALL remain usable at accessibility text sizes even if that means a wrapping layout instead of a compact segmented control.

#### Scenario: Accessibility text does not clip
- **WHEN** the user prefers an accessibility text size larger than the default
- **THEN** titles, guidance, result controls, progress, and actions remain fully readable without clipping

#### Scenario: Validation is announced
- **WHEN** New Audit create is activated with an invalid title
- **THEN** VoiceOver can discover the validation error associated with the title field

### Requirement: UI tests use an empty store and cover the happy path
UI tests SHALL launch with an isolated empty persistence store so they do not depend on existing user data. They SHALL cover creating an audit with a title, reviewing at least two criteria, adding one note, finishing, seeing the needs-attention item on the summary, and returning to Audits where the persisted audit appears. They SHALL also cover invalid empty-title validation. Identifiers used by tests SHALL be language-independent.

#### Scenario: Happy path from empty store
- **WHEN** a UI test launches with an empty store, creates an audit, sets two results including needsAttention, adds a note, and finishes
- **THEN** the summary represents the needs-attention item and returning to Audits shows that persisted audit

#### Scenario: Empty title UI validation
- **WHEN** a UI test launches with an empty store and activates create without a title
- **THEN** no audit appears in Audits and the validation error is present
