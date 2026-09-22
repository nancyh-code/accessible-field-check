## Context

See `proposal.md` for motivation and `specs/project-and-design-system-foundation/spec.md` for behavior.

The repo is a fresh Xcode SwiftUI template: `AccessibleFieldCheckApp` hosts `ContentView` ("Hello, world!"), Swift Testing and XCTest UI-test targets exist with placeholder tests, and there is no `.gitignore`. The generated project currently advertises iOS, macOS, and visionOS destinations, with `IPHONEOS_DEPLOYMENT_TARGET` set to 27.0. This change replaces the template UI and sets iOS 18+ as the V1 product baseline without stripping the extra destinations.

## Goals / Non-Goals

**Goals:**

- Keep the app a thin SwiftUI shell: views, value-type tokens, and a String Catalog.
- Make localization, Dynamic Type, and stable identifiers the default path for later screens.
- Leave a navigation seam (`newAudit`) that a later change can replace with the real audit flow.

**Non-Goals:**

- Do not introduce `@Observable`, `ObservableObject`, Combine, coordinators, repositories, use cases, actors, or networking.
- Do not build a component gallery, theme engine, or large token catalog.
- Do not add snapshot tests, accessibility-audit automation, or CI.
- Do not spend this change deleting already-generated macOS/visionOS destinations.

## Decisions

### Platform: iOS 18+, iPhone and iPad; keep extra generated destinations

Set the iOS deployment target to 18.0. V1 product QA is iPhone and iPad, portrait and landscape. The template already includes macOS and visionOS destinations; removing them would churn `project.pbxproj` without changing the product, so they stay. They are not V1 support targets.

Alternative considered: strip macOS/visionOS now. Rejected because it is unrelated to the foundation behavior and easy to get wrong in the pbxproj.

### Architecture: SwiftUI views and value types only

`AccessibleFieldCheckApp` hosts `AppRootView`. There is no shared app model in this change: Audits is always empty. Tokens and accessibility identifier constants are value types / enums. Do not add `@Observable` until a later change has real state.

Alternative considered: a root `AppModel` with `@Observable` holding an empty audits array. Rejected because it implies domain state that this change must not invent.

### Navigation: `NavigationStack` with a tiny destination enum

```swift
enum AppDestination: Hashable {
    case newAudit
}
```

`AppRootView` owns `NavigationStack(path:)` and registers `navigationDestination(for: AppDestination.self)`. `AuditsView` appends `.newAudit` from the primary action. `NewAuditPlaceholderView` is a non-persisting shell so the stack can be verified. No `TabView`.

Alternative considered: disable the CTA until persistence exists. Rejected because a real push is the cheapest way to prove navigation, and the spec requires a placeholder rather than fake business logic.

Alternative considered: `NavigationLink` without a path. Rejected because a one-case hashable destination is smaller to extend later than retrofitting a path.

### Design tokens: one small value-type surface mapped to system semantics

Keep tokens in a single `AFCTokens.swift` (or equivalent) with nested types:

- Spacing: xSmall 4, small 8, medium 16, large 24, xLarge 32
- Radius: small 8, medium 12, large 16
- Colors: `background` / `surface` / `primaryText` / `secondaryText` from system background and label colors; `accent` from the asset catalog accent; `success` / `warning` / `critical` from system green/orange/red so Dark Mode and Increase Contrast come from UIKit/SwiftUI semantics

Typography uses SwiftUI text styles (`.title2`, `.body`, `.headline`, `.caption`, `.subheadline`). No extra type-scale tokens.

Alternative considered: a large token catalog (numeric ramps, elevation, shadows). Rejected as out of scope.

### Components: three views, no fixed heights

| Component | Role |
| --- | --- |
| `AFCPrimaryButton` | Full-width (or naturally expanding) action; min 44 pt height; semantic `.headline` |
| `AFCStatusBadge` | Capsule/rounded label for pass / needsAttention / notApplicable; text + color (+ optional SF Symbol); never color-only |
| `AFCEmptyState` | Title, optional message slot, and a primary-action slot used by Audits |

Avoid `.frame(height:)`. Use `minHeight: 44` for interactive controls. Status badges appear in Xcode Previews; the New Audit placeholder may show the three badges as a static, non-interactive sample so the component is visible without implying an audit exists.

### Localization: String Catalog, Spanish development language

Use `Localizable.xcstrings`. Development language is Spanish (`es`); `en` is the secondary localization. Call sites use `String(localized:)` / `LocalizedStringResource` with keys, never user-facing string literals in views.

Keys:

- `navigation.audits.title` → Auditorías / Audits
- `audit.empty.title` → No hay auditorías todavía / No audits yet
- `audit.empty.action` → Nueva auditoría / New audit
- `audit.new.title` → Nueva auditoría / New audit
- `designSystem.status.pass` → Pasa / Pass
- `designSystem.status.needsAttention` → Requiere atención / Needs attention
- `designSystem.status.notApplicable` → No aplica / Not applicable

### Accessibility identifiers: language-independent constants

```text
audits.screen
audits.emptyState
audits.newAuditButton
newAudit.screen
```

Store them in `AFCAccessibilityID` so tests and views share one source. Identifiers stay English even when the UI is Spanish. Add `.accessibilityLabel` only when the visible text is not enough (for example a status badge whose visible text needs a fuller VoiceOver phrase).

Reduce Motion: this change adds no decorative animation. Later motion MUST check `accessibilityReduceMotion`.

### Testing: Swift Testing tokens + one XCTest UI smoke

- Unit: assert spacing, radius, and semantic color tokens exist (and that semantic colors are not `.clear`).
- UI: launch, `audits.screen` exists, `audits.newAuditButton` exists and is hittable. Replace the template example / launch-performance tests rather than stacking more.
- Do not UI-test Dynamic Type, VoiceOver, or locale switching in this change; those remain spec scenarios verified during implementation review.

### Public repository hygiene

Add a root `.gitignore` covering `xcuserdata/`, `DerivedData/`, `.DS_Store`, and secret-like files. Do not commit generated user schemes or personal files. No sample user data in this change.

### Expected commits during apply

1. `chore: plan project and design system foundation`
2. `feat: add Accessible Field Check app foundation`
3. `feat: add accessible design system`
4. `test: verify app accessibility foundation`
5. `chore: archive project and design system foundation`

## Risks / Trade-offs

- **[Risk] Extra macOS/visionOS destinations imply unsupported platforms.** → Mitigation: document iPhone/iPad as the V1 QA surface; do not add platform-specific UI in this change.
- **[Risk] New Audit placeholder looks like a real flow.** → Mitigation: keep copy and content clearly empty/placeholder; persist nothing.
- **[Risk] Token unit tests only prove constants exist, not visual quality.** → Mitigation: accepted; visual/Dynamic Type checks happen in Previews and implementation review.
- **[Trade-off] One destination enum now vs. adding it later.** → A one-case enum is less work than introducing `TabView` or a coordinator, and it matches the spec.

## Migration Plan

Greenfield template replacement. No user data, schema, or API to migrate. Rollback is reverting the implementation commits. The later audit-workflow change replaces `NewAuditPlaceholderView` and introduces persistence; it should not need to rewrite tokens, components, or the String Catalog layout.

## Open Questions

None. CTA behavior, platform matrix, and architecture were resolved above to match the spec.
