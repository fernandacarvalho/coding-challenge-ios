---
description: Audit and refactor a module's Composer against the project contract
argument-hint: <Module>
---

Audit the Composer of module **$ARGUMENTS** and propose fixes when it diverges from the contract documented in `CLAUDE.md`.

## Pre-flight checks

1. If `$ARGUMENTS` is empty, ask which module to audit.
2. Verify that `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/$ARGUMENTSUIComposer.swift` exists. If not, stop and suggest running `/new-module $ARGUMENTS`.

## What to read before proposing changes

Read the following files in this order:

1. `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/$ARGUMENTSUIComposer.swift`
2. `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/Presentation/$ARGUMENTSViewModel.swift`
3. Every file under `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/Domain/UseCases/`
4. Every file under `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/Domain/Repositories/`
5. Every file under `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/Data/Repositories/` and `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/Data/Services/`
6. `world-peek-ios/world-peek-ios/App/AppDependencies.swift`

## Validation rules

The Composer must satisfy ALL of the following:

| # | Rule |
|---|------|
| a | Declared as `enum $ARGUMENTSUIComposer` (not class/struct) |
| b | Has a single `static func make(...)` |
| c | First parameter is `deps: AppDependencies` (or a typed subset of it) |
| d | Other parameters are only **external** dependencies — navigation callbacks, IDs, preloaded data |
| e | Internal collaborators (UseCases/Repositories/Services owned by the module) are instantiated **inside** `make`, never received as parameters |
| f | Does **not** reference `DI.shared`, `AppDependencies.shared`, or any singleton |
| g | Wraps the SwiftUI View in `UIHostingController` |
| h | Returns `(UIViewController, $ARGUMENTSViewModel)` |
| i | Every parameter required by `$ARGUMENTSViewModel.init` is supplied in the call site |
| j | The Composer file imports `UIKit` and `SwiftUI`, but the ViewModel file does not |

## Reporting and applying fixes

1. List each rule violation found, citing the line in the Composer.
2. Propose a unified diff for the smallest set of changes that makes the Composer pass all rules. Show the diff inline.
3. **Wait for user approval** before applying any change. Use `Edit` only after the user confirms.
4. If the `make` signature changed (added/removed parameters), also update:
   - The corresponding `world-peek-iosTests/Modules/$ARGUMENTS/$ARGUMENTSUIComposerTests.swift` (if it exists), so `make_doesNotLeak` stays compilable.
   - All existing call sites of `$ARGUMENTSUIComposer.make` (typically inside `AppCoordinator` and other Composers).

## When to use this command

- After adding/removing a UseCase or changing the ViewModel's `init`.
- Suspicion that the Composer accesses a forbidden singleton.
- Pre-PR validation, to make sure the module still complies before merging.
