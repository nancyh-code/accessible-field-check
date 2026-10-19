## Context

See `proposal.md` for motivation. Product behavior stays the V1 already in the tree.

The app is a single Xcode project (`objectVersion` 110, `LastUpgradeCheck` 2700) with targets `AccessibleFieldCheck`, `AccessibleFieldCheckTests`, and `AccessibleFieldCheckUITests`. Local toolchain is Xcode 27.0 (27A266a). Deployment target is iOS 18.0. Marketing version is already 1.0. `xcodebuild -list` shows scheme `AccessibleFieldCheck`, but the scheme file is not in `xcshareddata`; user scheme state lives under ignored `xcuserdata`. There is no git remote, README, license, Fastlane, or GitHub Actions workflow.

GitHub’s `xcode-27` runner image is generally available and defaults to Xcode 27.0 build 27A266a, the same build used locally. This machine has an iPhone 17 simulator on iOS 27.0.

Existing tests to reuse, not extend:

- Swift Testing: design tokens, catalog, `AuditReviewProgress`, `AuditStore` including the persistence round trip.
- XCTest UI: empty-store happy path and empty-title validation, launched with `-ui-testing-empty-store`.

## Goals / Non-Goals

**Goals:**

- One required check on push to `main` and on pull requests.
- Fastlane lanes `test`, `build`, and `ci` as the only validation entry points.
- A README that describes the code that exists, plus MIT license and four manual demo images.
- A release checklist for a later human tag `v1.0.0`.

**Non-Goals:**

- Product features, new screens, new product tests, scoring, export, photos, AI, OCR, backend, sync, networking, analytics.
- App Store Connect, TestFlight, certificates, match, provisioning, release signing.
- Screenshot automation, coverage upload, nightly jobs, Xcode matrices, extra workflows, Tuist, XcodeGen, Swift packages, or app modularization.
- `ARCHITECTURE.md`, `CONTRIBUTING`, `CODEOWNERS`, issue templates, PR templates, changelog automation.
- Creating the `v1.0.0` tag, a GitHub remote, or a repository via this change.

## Decisions

### One workflow, Fastlane is the command

Add `.github/workflows/ci.yml` only. Triggers: `push` to `main`, and `pull_request`. `runs-on: xcode-27` (standard size, not `xcode-27-xlarge`).

Steps: checkout, select Xcode 27.0 explicitly (`/Applications/Xcode_27.0.app`), `bundle install`, `bundle exec fastlane ci`. No third-party setup action. The image default is already 27.0; the explicit select keeps a later 27.1 default on that image from changing the toolchain.

**Alternative:** call `xcodebuild` directly in the workflow and skip Fastlane on CI. Rejected because the workflow and laptops would drift.

**Alternative:** several workflows or a version matrix. Rejected; the project has one supported toolchain.

### UI tests stay in the required check

`test` and `ci` run the existing unit tests and the existing two UI tests on one destination: `platform=iOS Simulator,name=iPhone 17,OS=27.0`. The UI tests are deterministic (in-memory store, accessibility identifiers, no network). A second or non-blocking job is not justified for two cases.

**Alternative:** unit tests only, UI tests local. Rejected for the initial plan because the suites are already isolated and the runner is arm64. If the hosted simulator cannot finish them for infrastructure reasons, stop and revise this change. Do not add another workflow in the same implementation.

### Build lane does not distribute

`build` compiles for `generic/platform=iOS Simulator` with code signing disabled (`CODE_SIGNING_ALLOWED=NO`). It does not archive, export an IPA, or read an Appfile. `ci` runs `build`, then `test`.

**Alternative:** `gym` archive with automatic signing. Rejected; simulator validation does not need a distribution identity.

### Shared scheme

Commit `AccessibleFieldCheck.xcodeproj/xcshareddata/xcschemes/AccessibleFieldCheck.xcscheme` with the app target and both test targets. A clean runner cannot see `xcuserdata`.

### Fastlane surface

`Gemfile` pins Fastlane. Commit `Gemfile.lock`. `fastlane/Fastfile` defines `test`, `build`, and `ci` on the `ios` platform. No `Appfile`, `Matchfile`, `Snapfile`, or `fastlane init` README. Coverage stays off.

`.gitignore` already ignores `fastlane/report.xml`, `Preview.html`, and `test_output/`. Add `*.xcresult`, `vendor/`, and `.bundle/` if they are not already ignored. Do not ignore `Gemfile.lock`.

### README carries the architecture

One `README.md`. No `ARCHITECTURE.md`. The architecture section describes the current app:

- `AppRootView` owns one `NavigationStack` and `AppDestination` values `newAudit`, `checklist(UUID)`, `summary(UUID)`. No `TabView`.
- SwiftData `@Model` types `Audit` and `AuditItem`. Screens that need a live list use `@Query`. Mutations go through a concrete `AuditStore` constructed with the environment `ModelContext`.
- `AccessibilityCriterionCatalog` is a deterministic in-code catalog, not a persisted model.
- `AuditReviewProgress` is a pure value computed from results. It is not a view model.
- There is no view-model, repository, or use-case type. The flow is four screens over one store; another layer would only forward the same calls.
- Accessibility (Dynamic Type, VoiceOver, 44 pt targets, icon plus text plus semantic color) is a design constraint, not a later pass.

Also required in the README: overview, problem, demo, features, accessibility philosophy, data model, navigation, testing, CI/CD, localization (Spanish source, English in the string catalog, `developmentRegion = es`), stack, project structure, engineering decisions, non-goals, how to run, how to run tests, roadmap, license. State plainly that the app is not a legal compliance tool, does not certify WCAG conformance, and stores structured review observations only.

Suggested GitHub description, written in the README so it can be copied when a remote exists: “Structured accessibility review for mobile apps. Observations only — not a WCAG certification or legal compliance tool.” Do not create the remote here.

**Alternative:** a separate architecture doc. Rejected; the README section is the public explanation, and a second file would repeat it.

### Manual demo, four images

Add `docs/demo/` with four PNG screenshots, in this order:

1. Audits list with one sample audit
2. New Audit
3. Checklist with a few results set
4. Summary

Capture them by hand in the Simulator from sample content, for example title `Library home` and a note such as `Increase the button hit area.` No personal names, account data, machine paths, or the developer’s real audits. Document those sample strings in the README so a recapture stays deterministic. Do not add a seed launch argument or a snapshot lane.

**Alternative:** Fastlane Snapshot. Rejected; it needs UI-test harness work and is more machinery than four images.

### License and files that stay out

`LICENSE` is MIT, copyright Nancy Hernandez, matching the existing source headers. No `CONTRIBUTING`: clone, open, and test are already README sections, and there is no review process to document.

### Release tag stays manual

Marketing version stays 1.0. Implementation does not run `git tag`. The README CI/CD section includes the checklist: build green, unit tests green, UI tests green locally, GitHub Actions green, Fastlane lanes green, OpenSpec valid, clean git status, README complete, no secrets, demo ready. There is no remote today, so a hosted Actions run cannot be observed until the branch is pushed. Local verification is `bundle exec fastlane ci` on Xcode 27.0. If no hosted run exists yet, the checklist item stays open and the tag is still not created.

### Expected commits during apply

1. `chore: plan CI and public release`
2. `ci: add GitHub Actions and Fastlane`
3. `docs: prepare public repository`
4. `test: verify v1 release readiness`
5. `chore: archive CI and public release`

## Risks / Trade-offs

- **[Risk] The hosted iOS 27 simulator uses a different iPhone name than `iPhone 17`.** → Mitigation: keep a single destination. If the image has no iPhone 17 on iOS 27.0, switch the name once and use that same string locally and in CI. Do not add a device matrix.
- **[Risk] UI tests fail on the hosted runner because the simulator does not boot, not because an assertion failed.** → Mitigation: stop and revise the spec. Do not weaken the job with `continue-on-error` or a second workflow inside this change.
- **[Risk] No git remote, so “GitHub Actions green” cannot be checked here.** → Mitigation: local `fastlane ci` is the verification this change can perform. Leave the hosted item unchecked until a push exists. Do not create a remote just to go green.
- **[Trade-off] `ci` builds twice (generic build, then test).** → Accepted. The generic build proves signing-free compilation; test proves the suites. Both are cheap next to a second toolchain.
- **[Trade-off] MIT is assumed.** → Accepted from the proposal. Replacing the license file is the only edit if a different license is chosen before implementation.

## Migration Plan

No schema or user-data migration. Rollback is reverting the implementation commits. The app binary and SwiftData store are unchanged.

## Open Questions

None. Toolchain, destination, UI tests in the single check, manual screenshots, MIT, and the manual tag are decided above.
