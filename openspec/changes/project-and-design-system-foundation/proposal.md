## Why

Accessible Field Check is a new local-first iOS portfolio app. The generated Xcode template still shows "Hello, world!" and has no navigation, design system, localization, accessibility contract, or public-repo hygiene. Establishing those foundations first keeps later audit workflow work from inheriting inaccessible, unlocalized, or hardcoded UI.

## What Changes

- Replace the template `ContentView` with an Accessible Field Check app shell whose single primary destination is Audits.
- Add `NavigationStack` navigation with a temporary New Audit placeholder reached from the empty-state CTA. Do not add `TabView`.
- Add a small design-system token set (spacing, corner radius, semantic colors) and three reusable accessible components.
- Add Spanish as the source language and English as the secondary localization, with namespaced string keys.
- Apply accessibility foundations from the first screen: Dynamic Type, VoiceOver labels where needed, practical touch targets, semantic color, non-color meaning, Reduce Motion policy, and stable accessibility identifiers.
- Show an empty Audits landing screen (`No hay auditorías todavía` / `Nueva auditoría`) with no persisted audit domain.
- Establish Swift Testing for meaningful design-system checks and a minimal XCTest UI smoke test (launch, Audits reachable, primary CTA accessible).
- Add public-repository hygiene (`.gitignore`, no secrets, no personal/generated user files).

Out of scope for this change: SwiftData, Audit persistence, checklist business logic, photos, export, networking, login, sync, AI, OCR, maps, PDF, analytics, GitHub Actions, and Fastlane.

## Capabilities

### New Capabilities

- `project-and-design-system-foundation`: App shell, NavigationStack, empty Audits landing, design tokens, reusable accessible components, localization, accessibility foundations, and baseline tests.

### Modified Capabilities

- None. There are no existing main specs.

## Impact

- App target: replace template UI with `App` scene, Audits landing, and a New Audit placeholder.
- New design-system and component files; String Catalog (or equivalent) for `es` source and `en` secondary.
- `AccessibleFieldCheckTests` (Swift Testing) and `AccessibleFieldCheckUITests` (XCTest smoke).
- Xcode project settings: iOS 18+ deployment, localization, accessibility identifiers. Keep already-generated macOS/visionOS destinations if removing them would add churn; V1 product QA is iPhone and iPad.
- New `.gitignore` so `xcuserdata`, secrets, and generated user data never enter the public repository.
- No new packages, networking, persistence, or architecture layers.
