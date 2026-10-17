# project-and-design-system-foundation Specification

## Purpose
Defines the Accessible Field Check iOS app shell, hierarchical navigation, empty Audits landing, small design-system tokens, reusable accessible components, localization, accessibility foundations, and baseline automated tests — without any audit persistence or checklist workflow.

## Requirements

### Requirement: App shell presents Audits as the single primary destination
The app SHALL launch into a single hierarchical navigation stack whose root destination is Audits. The app SHALL NOT present a tab bar. The Audits destination SHALL remain usable on iPhone and iPad in portrait and landscape.

#### Scenario: Launch shows Audits
- **WHEN** the app launches
- **THEN** the user sees Audits as the primary screen

#### Scenario: No tab bar
- **WHEN** the app launches
- **THEN** no tab bar is shown

#### Scenario: iPhone and iPad orientations
- **WHEN** the Audits screen is shown on iPhone or iPad in portrait or landscape
- **THEN** the empty-state message remains readable and the primary action remains reachable

### Requirement: Empty Audits landing communicates that no audits exist
When the user has no audits, the Audits screen SHALL show an empty state. The source-language copy SHALL be "No hay auditorías todavía". The English copy SHALL be "No audits yet".

#### Scenario: Spanish empty copy
- **WHEN** the app locale is Spanish and the user has no audits
- **THEN** the empty state displays "No hay auditorías todavía"

#### Scenario: English empty copy
- **WHEN** the app locale is English and the user has no audits
- **THEN** the empty state displays "No audits yet"

### Requirement: Small design-system token set
Foundation screens and reusable components SHALL use a small shared token set. Spacing tokens SHALL be xSmall, small, medium, large, and xLarge. Corner-radius tokens SHALL be small, medium, and large. Semantic color tokens SHALL be background, surface, primaryText, secondaryText, accent, success, warning, and critical. Body and title typography SHALL use semantic system text styles rather than hardcoded point sizes.

#### Scenario: Required tokens exist
- **WHEN** the design-system token set is verified
- **THEN** all listed spacing, corner-radius, and semantic color tokens are present

#### Scenario: Typography uses semantic styles
- **WHEN** text is shown on the Audits empty state or the primary action
- **THEN** that text uses a semantic system text style rather than a hardcoded point size

### Requirement: Reusable accessible components
The foundation SHALL provide a primary button, a status badge, and an empty-state component. The status badge SHALL represent Pass, Needs attention, and Not applicable with localized text in addition to color. These components SHALL remain readable at accessibility text sizes without clipping caused by fixed heights. Meaning SHALL never rely on color alone.

#### Scenario: Status meaning is not color-only
- **WHEN** a status badge is shown for Pass, Needs attention, or Not applicable
- **THEN** the badge includes localized text for that status in addition to color

#### Scenario: Components scale with Dynamic Type
- **WHEN** the user prefers an accessibility text size larger than the default
- **THEN** the primary button, status badge, and empty-state text remain fully readable without clipping

### Requirement: Spanish source language with English secondary localization
User-facing strings SHALL come from a localization catalog rather than scattered hardcoded literals. The source language SHALL be Spanish. English SHALL be provided as a secondary localization. String keys SHALL use the namespaces `audit.*`, `designSystem.*`, and `navigation.*` as appropriate. Accessibility identifiers SHALL stay stable across languages.

#### Scenario: Spanish is the source language
- **WHEN** the app locale is Spanish
- **THEN** user-facing copy on the Audits screen is Spanish, including the navigation title "Auditorías"

#### Scenario: English localization is available
- **WHEN** the app locale is English
- **THEN** user-facing copy on the Audits screen is English, including the navigation title "Audits"

### Requirement: Accessibility foundation on the first screens
The Audits landing and New Audit form SHALL support Dynamic Type. Interactive controls SHALL provide a minimum tappable area of 44 by 44 points. VoiceOver labels SHALL be supplied where system inference is insufficient. These screens SHALL NOT play decorative animation. UI tests SHALL be able to locate the Audits screen and the primary action through stable, language-independent accessibility identifiers.

#### Scenario: Primary action meets the minimum touch target
- **WHEN** the empty Audits screen is shown
- **THEN** the New Audit control’s tappable area is at least 44 by 44 points

#### Scenario: No decorative motion
- **WHEN** the Audits screen or New Audit form is shown
- **THEN** the screens do not play decorative animation

#### Scenario: Stable identifiers for UI tests
- **WHEN** a UI test queries the launched app in Spanish or English
- **THEN** it can locate the Audits screen and the New Audit action by the same accessibility identifiers

### Requirement: Baseline automated tests
The project SHALL include Swift Testing unit tests that verify the required design-system tokens exist. The project SHALL include an XCTest UI smoke test that launches the app, reaches the Audits screen, and confirms the primary action is present and accessible. The test suite SHALL NOT expand into a broad regression catalog in this change.

#### Scenario: Unit tests cover design tokens
- **WHEN** the unit-test suite runs
- **THEN** it verifies that the required spacing, corner-radius, and semantic color tokens exist

#### Scenario: UI smoke test covers the launch path
- **WHEN** the UI-test suite runs
- **THEN** it launches the app, finds the Audits screen by accessibility identifier, and finds the primary action by accessibility identifier
