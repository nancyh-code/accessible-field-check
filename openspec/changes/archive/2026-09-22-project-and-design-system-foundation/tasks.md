## 1. App and navigation foundation

- [x] 1.1 Add a root `.gitignore` that excludes `xcuserdata/`, `DerivedData/`, `.DS_Store`, and secret-like files, and verify `git status` no longer lists personal Xcode user data.
- [x] 1.2 Set `IPHONEOS_DEPLOYMENT_TARGET` to 18.0 without removing already-generated macOS/visionOS destinations, and verify the pbxproj shows 18.0 while those destinations remain.
- [x] 1.3 Replace `ContentView` with `AppRootView` hosting `NavigationStack` and `AppDestination`, point `AccessibleFieldCheckApp` at it, and verify the app launches to Audits with no tab bar.
- [x] 1.4 Add `AuditsView` (empty landing) and `NewAuditPlaceholderView`, wire the primary action to push `.newAudit`, and verify navigating back still shows the empty Audits state with nothing persisted.

## 2. Minimal design system

- [x] 2.1 Add `AFCTokens` with spacing (xSmall…xLarge), radius (small…large), and semantic colors from `design.md`, and verify all required tokens exist as value-type constants.
- [x] 2.2 Add `AFCPrimaryButton` using token spacing/colors, a semantic text style, and `minHeight` 44 rather than a fixed height, and verify it scales with Dynamic Type in Previews.
- [x] 2.3 Add `AFCStatusBadge` for pass, needsAttention, and notApplicable with text plus color (optional SF Symbol), and verify each status remains understandable without color.
- [x] 2.4 Add `AFCEmptyState` and wire `AuditsView` to the empty-state and primary-button components, and verify the landing screen uses tokens instead of one-off padding and colors.

## 3. Localization, accessibility, and tests

- [x] 3.1 Add `Localizable.xcstrings` with Spanish source and English secondary using the `navigation.*`, `audit.*`, and `designSystem.*` keys in `design.md`, and verify Audits copy matches the spec in both locales with no hardcoded user-facing literals in views.
- [x] 3.2 Add `AFCAccessibilityID` (`audits.screen`, `audits.emptyState`, `audits.newAuditButton`, `newAudit.screen`), apply identifiers, 44 pt touch targets, and VoiceOver labels only where needed, and verify the screens have no decorative animation.
- [x] 3.3 Add Swift Testing coverage in the unit-test target that asserts the required spacing, radius, and semantic color tokens exist and are not `.clear`, and verify the template example test is replaced or removed.
- [x] 3.4 Replace template UI tests with one XCTest smoke test that launches the app, finds `audits.screen`, and finds a hittable `audits.newAuditButton`, and verify no extra UI tests are added.
- [x] 3.5 Build the app, unit tests, and UI tests for an iPhone simulator and verify they pass without SwiftData, networking, `TabView`, or audit persistence.
