## Why

Accessible Field Check already has a working V1 review flow, but a public portfolio reader cannot build, test, or understand it without local knowledge. The repository has no CI, no Fastlane, no README, and no license, so it is not yet a release-ready public V1.

## What Changes

- Add one GitHub Actions workflow that builds the app for the iOS Simulator and runs the existing tests on push to `main` and on pull requests, with no code signing, secrets, or store upload.
- Pin that workflow to the Xcode 27.0 toolchain on the `xcode-27` hosted runner, matching the local Xcode 27.0 (27A266a) project.
- Add a minimal Fastlane setup with `test`, `build`, and `ci` lanes. The workflow calls `ci`.
- Add a public README, an MIT license, a 3–4 image manual demo set, and a small `.gitignore` pass so the repo is safe to publish.
- Document the real architecture in the README and state the V1 boundaries: this is not a legal compliance tool, it does not certify WCAG conformance, and results are structured review observations only.
- Verify release readiness for a later manual `v1.0.0` tag. This change does not create the tag.

No product screens, scoring, export, or other V1 behavior changes.

## Capabilities

### New Capabilities

- `ci-fastlane-and-public-release`: Simulator CI, Fastlane validation lanes, public README and license, deterministic demo screenshots, repository hardening, and the pre-tag V1 release check.

### Modified Capabilities

- None. Product requirements in `audit-flow-and-accessibility`, `audit-domain-and-persistence`, and `project-and-design-system-foundation` stay as they are.

## Impact

- New repo files: `.github/workflows/ci.yml`, `Gemfile`, `Gemfile.lock`, `fastlane/Fastfile`, `README.md`, `LICENSE`, and a small `docs/demo/` screenshot set.
- Project config: commit a shared `AccessibleFieldCheck` scheme so a clean checkout can build and test. The scheme is user-only today (`xcuserdata` is ignored).
- `.gitignore`: add only the gaps found while reviewing (test results, Bundler vendor paths). Existing secret and DerivedData ignores stay.
- No Swift product changes, no new test cases, no dependency managers for the app, no App Store Connect, TestFlight, match, or signing automation.
- Assumption: the public license is MIT. A different license would replace `LICENSE` only.
