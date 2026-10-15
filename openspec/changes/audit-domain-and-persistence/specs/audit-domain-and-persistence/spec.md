## Purpose

Defines the Accessible Field Check audit domain, a deterministic built-in mobile-app accessibility criterion catalog, local persistence of audits and review items, and the integrity rules needed before any checklist UI exists.

## ADDED Requirements

### Requirement: Deterministic built-in criterion catalog
The system SHALL provide a built-in catalog of exactly 12 mobile-app accessibility criteria. Each criterion SHALL have a stable unique identifier, a title localization key, a category, a guidance localization key, and a sort order. Catalog identity SHALL NOT depend on localized display strings. The catalog SHALL NOT be persisted. Categories SHALL be textAndContent, interaction, navigation, and feedbackAndErrors. The 12 criterion identifiers SHALL be: dynamicType, voiceOverLabels, touchTargetSize, colorContrast, colorIndependentMeaning, focusOrder, errorIdentification, formLabels, modalAccessibility, reduceMotion, contentScaling, and clearButtonLabels.

#### Scenario: Catalog size and unique IDs
- **WHEN** the built-in catalog is loaded
- **THEN** it contains exactly 12 criteria whose identifiers are unique and match the required identifier set

#### Scenario: Catalog uses localization keys
- **WHEN** a criterion is read from the catalog
- **THEN** its title and guidance are localization keys, not translated display strings

### Requirement: Creating a draft audit populates review items
Creating a draft audit SHALL require a caller-supplied title and SHALL produce an audit with a unique identifier, that title, createdAt and updatedAt timestamps, status draft, and exactly one review item per catalog criterion. The title SHALL be user-authored data. The system SHALL NOT persist a localized default title. Each review item SHALL have a unique identifier, the corresponding criterion identifier, result notReviewed, no note, and an updatedAt timestamp. The audit SHALL NOT contain duplicate criterion identifiers.

#### Scenario: Draft includes every catalog criterion
- **WHEN** a draft audit is created with a caller-supplied title
- **THEN** it has that same title, status draft, and one notReviewed item for each catalog criterion

#### Scenario: No duplicate criteria in a new audit
- **WHEN** a draft audit is created
- **THEN** each criterion identifier appears on exactly one item of that audit

#### Scenario: New items have no note
- **WHEN** a draft audit is created
- **THEN** every item has an empty optional note

### Requirement: Review results and notes can be updated
The system SHALL allow updating an item result to pass, needsAttention, notApplicable, or notReviewed. The system SHALL allow adding, editing, and removing an optional note on an item. Updating an item SHALL set that item’s updatedAt and the parent audit’s updatedAt to the operation time so ordering and tests remain deterministic.

#### Scenario: Result update
- **WHEN** an item result is set to pass
- **THEN** later reads of that audit return pass for that item

#### Scenario: Note add edit and remove
- **WHEN** a note is added, then edited, then removed
- **THEN** later reads show the edited text after the edit and no note after removal

### Requirement: Completion keeps items and reopen restores draft
Marking an audit completed SHALL set status to completed and SHALL NOT delete or rewrite items, including items still notReviewed. Reopening an audit SHALL set status to draft and SHALL preserve existing results and notes.

#### Scenario: Complete does not discard unfinished items
- **WHEN** an audit with at least one notReviewed item is marked completed
- **THEN** its status is completed and those notReviewed items remain

#### Scenario: Reopen preserves results
- **WHEN** a completed audit is reopened
- **THEN** its status is draft and previously stored results and notes are unchanged

### Requirement: Audits are fetched newest first
Fetching audits SHALL return persisted audits ordered by updatedAt descending.

#### Scenario: Fetch order
- **WHEN** two audits exist and the older one is updated later
- **THEN** fetch returns that updated audit before the other

### Requirement: Persistence round-trip preserves audit data
Persisted audits, items, results, notes, timestamps, and status SHALL be readable after a new persistence context is created against the same store. Item results SHALL remain notReviewed until explicitly updated.

#### Scenario: Reload after save
- **WHEN** a draft audit is created, one item is set to needsAttention with a note, and a new persistence context loads the store
- **THEN** the audit is found with the same identifiers, status, result, note, and timestamps

#### Scenario: Default result after reload
- **WHEN** a newly created draft is reloaded without item edits
- **THEN** every item result is still notReviewed

### Requirement: Criterion localization keys exist for the catalog
The String Catalog SHALL include Spanish source and English secondary strings for each criterion title, each criterion guidance, and each criterion category. These keys SHALL NOT be stored as the persisted identity of a criterion. Localized presentation strings SHALL NOT be persisted as `Audit.title`.

#### Scenario: Spanish and English catalog copy
- **WHEN** the localization catalog is inspected
- **THEN** each of the 12 criteria has Spanish and English title and guidance strings, and each category has Spanish and English strings
