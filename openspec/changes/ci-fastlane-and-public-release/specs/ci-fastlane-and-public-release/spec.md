## Purpose

Defines how Accessible Field Check is validated and presented as a public V1: one signing-free continuous-integration check, three Fastlane lanes, a README that matches the real app, deterministic demo images, a publishable repository, and a release checklist that does not create a git tag.

## ADDED Requirements

### Requirement: Continuous integration validates a clean checkout
The repository SHALL provide one automated check that runs on every push to main and on every pull request. That check SHALL build the iOS app for the Simulator and SHALL run the existing unit tests and the existing UI tests. A build failure or a test failure SHALL fail the check. The check SHALL NOT require secrets, distribution code signing, or an App Store or TestFlight upload. The check SHALL NOT be split into multiple workflows, an Xcode-version matrix, or a scheduled job.

#### Scenario: Pull request is checked
- **WHEN** a pull request is opened or updated
- **THEN** the check builds the app for the iOS Simulator and runs the existing unit tests and UI tests

#### Scenario: Main is checked the same way
- **WHEN** a commit is pushed to main
- **THEN** the same check runs

#### Scenario: Failure blocks the check
- **WHEN** the Simulator build or any included test fails
- **THEN** the check fails

#### Scenario: No secrets or upload
- **WHEN** the check runs
- **THEN** it finishes without repository secrets, a distribution certificate, or an App Store or TestFlight upload

### Requirement: The toolchain is explicit
The check SHALL select Xcode 27.0. Project documentation SHALL state that local development uses Xcode 27.0 and that the deployment target is iOS 18.0. The check SHALL NOT add a job for any older Xcode version.

#### Scenario: CI uses Xcode 27.0
- **WHEN** the check runs
- **THEN** it uses Xcode 27.0

#### Scenario: Docs state the local toolchain
- **WHEN** a reader opens the project documentation
- **THEN** it names Xcode 27.0 and deployment target iOS 18.0

### Requirement: Fastlane validates without distributing
The repository SHALL provide three lanes named test, build, and ci. The test lane SHALL run the existing unit tests and the existing UI tests. The build lane SHALL build the app for validation without distribution signing. The ci lane SHALL be what the continuous-integration check runs, and it SHALL compose that validation. None of the lanes SHALL upload a build, manage certificates, or run match.

#### Scenario: Test lane runs the existing suites
- **WHEN** the test lane runs
- **THEN** the existing unit tests and UI tests run

#### Scenario: Build lane does not sign for distribution
- **WHEN** the build lane runs
- **THEN** the app builds for validation and no distribution certificate or provisioning profile is required

#### Scenario: CI lane matches the check
- **WHEN** the continuous-integration check runs
- **THEN** it uses the ci lane, and that lane does not upload a build

### Requirement: The README presents the public V1
The repository SHALL include a README with these sections: project overview, the problem being solved, screenshots or demo, core features, accessibility philosophy, architecture, data model, navigation flow, testing strategy, CI/CD, localization, technology stack, project structure, engineering decisions, non-goals and V1 boundaries, how to run, how to run tests, roadmap or future ideas, and license. The README SHALL state that the app is not a legal compliance tool, that it does not certify WCAG conformance, and that results are structured review observations only. The architecture section SHALL describe the implementation that exists: one SwiftUI NavigationStack, SwiftData, @Query, ModelContext, a concrete AuditStore, an in-code criterion catalog, pure AuditReviewProgress, no view-model layer, no repository or use-case abstraction, and accessibility as a first-class constraint.

#### Scenario: Required sections are present
- **WHEN** a reader opens the README
- **THEN** each required section is present

#### Scenario: Compliance boundary is explicit
- **WHEN** a reader opens the README
- **THEN** it states that the app is not a legal compliance tool, does not certify WCAG conformance, and records structured review observations only

#### Scenario: Architecture matches the code
- **WHEN** a reader reads the architecture section
- **THEN** it describes NavigationStack, SwiftData, @Query, ModelContext, AuditStore, the in-code catalog, AuditReviewProgress, the absence of a view model, and the absence of a repository or use-case layer

### Requirement: Demo images use sample data
The repository SHALL include three or four screenshots that together show the Audits list or its empty state, New Audit, the checklist, and the summary. Those images SHALL be captured from deterministic sample data. They SHALL NOT show personal data, a local machine path, or a private audit. Screenshot capture SHALL be manual. The change SHALL NOT add screenshot automation.

#### Scenario: The demo set covers the flow
- **WHEN** a reader opens the demo images
- **THEN** there are three or four images covering the Audits list or empty state, New Audit, the checklist, and the summary

#### Scenario: Sample content is not personal
- **WHEN** the demo images are reviewed
- **THEN** titles and notes are generic sample data and do not identify a person or a local machine

### Requirement: The repository is safe to publish
The repository SHALL ignore Xcode user data, DerivedData, secret files, and local test output. It SHALL include an MIT license. It SHALL NOT commit secrets, simulator data, test-result bundles, or personal identifiers in sample content. It SHALL NOT add CODEOWNERS, issue templates, pull request templates, or changelog automation.

#### Scenario: Local and secret files stay untracked
- **WHEN** ignore rules are reviewed
- **THEN** user-specific Xcode data, DerivedData, secret files, and test output are ignored

#### Scenario: License is present and extras are absent
- **WHEN** the repository root is inspected
- **THEN** an MIT license is present, and CODEOWNERS, issue templates, pull request templates, and changelog automation are absent

### Requirement: V1 is verified before any tag
Release readiness SHALL be recorded against this checklist: build green, unit tests green, UI tests green locally, the continuous-integration check green, Fastlane lanes green, OpenSpec valid, clean git status, README complete, no secrets, and demo images ready. A failed or not-yet-observed item SHALL mean the version is not ready to tag. This change SHALL NOT create the git tag v1.0.0.

#### Scenario: Checklist is the release gate
- **WHEN** release readiness is assessed
- **THEN** each checklist item is recorded, and any failed or not-yet-observed item leaves the version untagged

#### Scenario: The tag is not created
- **WHEN** this change is complete
- **THEN** git tag v1.0.0 has not been created by the change
