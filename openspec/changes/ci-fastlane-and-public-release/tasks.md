## 1. GitHub Actions and Fastlane

- [x] 1.1 Commit a shared `AccessibleFieldCheck` scheme that builds the app and runs `AccessibleFieldCheckTests` and `AccessibleFieldCheckUITests`, and verify the scheme file is under `xcshareddata` and `xcodebuild -list` shows it.
- [x] 1.2 Add `Gemfile`, `Gemfile.lock`, and `fastlane/Fastfile` with lanes `test`, `build`, and `ci` only, and verify `bundle exec fastlane lanes` lists those three and no upload, match, or snapshot lane.
- [x] 1.3 Add `.github/workflows/ci.yml` as the only workflow, triggered on push to `main` and on `pull_request`, using `xcode-27`, selecting Xcode 27.0, and running `bundle exec fastlane ci` with no secrets, and verify no second workflow or version matrix exists.
- [x] 1.4 Run `bundle exec fastlane ci` on local Xcode 27.0 for the iPhone 17 / iOS 27.0 simulator, and verify the signing-free build, existing unit tests, and existing UI tests pass.

## 2. README, repository hardening, and demo

- [ ] 2.1 Add `README.md` with every required section, Xcode 27.0, deployment target iOS 18.0, the actual architecture, the compliance boundary, the suggested repository description, and the release checklist, and verify each section is present.
- [ ] 2.2 Add an MIT `LICENSE` with copyright Nancy Hernandez, and verify the file is that license.
- [ ] 2.3 Review `.gitignore` and the tree, ignore `*.xcresult`, `vendor/`, and `.bundle/` where missing, and verify user data, DerivedData, secrets, and Fastlane output stay ignored and no secrets or personal sample data are tracked.
- [ ] 2.4 Add four manual screenshots under `docs/demo/` for the Audits list, New Audit, checklist, and summary using the README sample strings, and verify the README links those images and no snapshot lane was added.
- [ ] 2.5 Leave out `ARCHITECTURE.md`, `CONTRIBUTING`, `CODEOWNERS`, issue templates, pull request templates, and changelog automation, and verify those files are absent.

## 3. Release verification

- [ ] 3.1 Review the diff and verify it contains no new product screens, product tests, scoring, export, networking, or signing automation.
- [ ] 3.2 Run `openspec validate ci-fastlane-and-public-release --strict --type change` and verify the change is valid.
- [ ] 3.3 Record the release checklist, mark the hosted Actions run not-yet-observed when no remote exists, and verify `git tag -l v1.0.0` is empty.
