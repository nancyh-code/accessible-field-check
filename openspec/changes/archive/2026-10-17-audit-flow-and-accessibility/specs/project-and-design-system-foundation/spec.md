## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: Empty state offers a New Audit action that opens a placeholder
**Reason**: The V1 workflow replaces the non-persisting placeholder with a real New Audit form that can create a draft and open the checklist.
**Migration**: Keep the empty-state New Audit action and `newAudit.screen` identifier. Implement the form, validation, and persistence behavior in `audit-flow-and-accessibility`. Opening New Audit and navigating back without a valid submit SHALL still leave Audits empty.
