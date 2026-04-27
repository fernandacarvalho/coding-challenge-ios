---
description: Review the current Swift file against the project's architecture, style, and testing rules
---

Review the file currently being edited (or the file the user names in the conversation) against the rules documented in `CLAUDE.md`. Report each violation with the file path and line number, then offer fixes the user can approve.

If no file is currently selected and the user has not named one, ask which file to review.

## Checklist

For every applicable rule, mark **PASS** or **FAIL** with a short explanation. Do not silently skip a rule — say "N/A" if it doesn't apply.

### Code style

- [ ] No force unwrap (`!`) anywhere in the file
- [ ] No implicitly unwrapped optionals (`Type!` declarations)
- [ ] Closures with potential long lifetime use `[weak self]`
- [ ] `final class` is used wherever inheritance is not required
- [ ] Naming follows project conventions: `UseCasing` for use case protocols, `Repository` for repository protocols, `Service` for service protocols
- [ ] Async APIs use `async/await`, not completion handlers

### Architecture

- [ ] If the file is a ViewModel: it does NOT import `UIKit` or `SwiftUI`
- [ ] If the file is a ViewModel: state exposed to the View is `@Published` (typically `@Published private(set) var ...`)
- [ ] If the file is a ViewModel: navigation events are exposed as closures (e.g. `onCountrySelected: ((Country) -> Void)?`), not handled inside the ViewModel
- [ ] If the file is a SwiftUI View: it does NOT use `NavigationStack`, `NavigationLink`, `NavigationView`, or `navigationDestination(for:)`
- [ ] If the file is a SwiftUI View: it binds to the ViewModel via `@StateObject` (entry-point) or `@ObservedObject` (subview)
- [ ] If the file is a Composer: it is an `enum` with a single `static func make(...)`
- [ ] If the file is a Composer: first parameter is `deps: AppDependencies`; remaining parameters are only external deps
- [ ] If the file is a Composer: it does NOT reference `DI.shared`, `AppDependencies.shared`, or any singleton
- [ ] If the file is a Composer: it wraps the SwiftUI View in `UIHostingController` and returns `(UIViewController, ViewModel)`
- [ ] If the file lives inside `Modules/<Module>/`: it does NOT import internal layers (Data/Presentation/View) of any other module

### Testing rules (when reviewing a `*Tests.swift` file)

- [ ] Uses `import Testing` (NOT `import XCTest`)
- [ ] Suite is declared as `@Suite final class <Name>: LeakTrackingTestSuite`
- [ ] `typealias SUT`, `struct Spies`, and `func makeSUT() -> (SUT, Spies)` live in a `private extension` at the bottom of the file
- [ ] `trackForMemoryLeaks([sut, ...spies])` is called inside `makeSUT`
- [ ] `Spies` struct contains only spies, no reference to the SUT
- [ ] Variations of the same behavior use `@Test(arguments:)` instead of N near-duplicate tests
- [ ] Spies follow the project pattern: `final class`, `private(set) var <method>CallsCount`, `<method>Received<Param>`, `var <method>ToBeReturned`
- [ ] Fixtures (`Type.fixture(...)`) are used instead of literal struct construction when a fixture exists
- [ ] If the file is a `*UIComposerTests.swift`: it contains ONLY `make_doesNotLeak`. Any other test is a violation — composers must contain no logic.

## Reporting format

For each FAIL, output:

```
- <file>:<line> — <rule violated>
  Why: <one short sentence on what is wrong>
  Suggested fix: <smallest change to make it pass>
```

After listing violations, offer to apply the fixes via `Edit`. Wait for the user to approve before changing anything.

If the file passes all checks, say so explicitly and stop.
