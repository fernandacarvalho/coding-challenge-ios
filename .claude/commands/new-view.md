---
description: Create a SwiftUI View inside a module, optionally with a ViewModel
argument-hint: <Module> <ViewName> [--with-viewmodel | --no-viewmodel]
---

Create a new SwiftUI View named after the second argument inside the module given by the first argument.

Arguments: `$ARGUMENTS`

## Argument parsing

Parse `$ARGUMENTS` as: `<Module> <ViewName> [--with-viewmodel | --no-viewmodel]`

- If fewer than two tokens are present, ask for the missing pieces.
- Treat the third token, if present, as the ViewModel flag.

## Pre-flight checks

1. Verify that `world-peek-ios/world-peek-ios/Modules/<Module>/` exists. If not, stop and suggest running `/new-module <Module>` first.
2. Verify that `<Module>/View/<ViewName>.swift` does not already exist. If it does, stop and report it.

## ViewModel decision

- `--with-viewmodel`: also create a ViewModel.
- `--no-viewmodel`: only create the View. Used for stateless components (e.g. `CountryRowView`, `FlagBadgeView`).
- If no flag is provided: **ask the user** before generating files. Explain the trade-off:
  - "with ViewModel" — for full screens with state/logic/UseCases
  - "no ViewModel" — for pure subviews that receive data via init/@Binding

## What to create

### Always: `Modules/<Module>/View/<ViewName>.swift`

If a ViewModel is being created:
```swift
import SwiftUI

struct <ViewName>: View {
    @StateObject var viewModel: <ViewName>ViewModel

    var body: some View {
        // TODO: implement
        EmptyView()
    }
}
```

If no ViewModel:
```swift
import SwiftUI

struct <ViewName>: View {
    // TODO: declare the data this view needs as init parameters or @Binding

    var body: some View {
        // TODO: implement
        EmptyView()
    }
}
```

### Conditional: `Modules/<Module>/Presentation/<ViewName>ViewModel.swift`

Only when `--with-viewmodel` is selected:
```swift
import Foundation

@MainActor
final class <ViewName>ViewModel: ObservableObject {
    // Expose state to the View via @Published properties only.
    // Use private(set) so the View can read but only the ViewModel mutates.
    // @Published private(set) var <state>: <Type> = <default>

    // Inject dependencies via init using protocols.
    // Expose closures for navigation events; never import UIKit/SwiftUI here.

    init() {
        // TODO: replace with real dependencies
    }
}
```

## Rules to enforce

- Do **not** create `Domain/` or `Data/` folders.
- The ViewModel file must **not** import `UIKit` or `SwiftUI`.
- ViewModels are `@MainActor final class` conforming to `ObservableObject`.
- Any state the View reads from the ViewModel must be a `@Published` property (typically `@Published private(set) var ...`). The View binds to the ViewModel via `@StateObject` (entry-point view) or `@ObservedObject` (subviews receiving the existing ViewModel).
- View files must not contain navigation primitives (`NavigationStack`, `NavigationLink`, `NavigationView`). Navigation is delegated to the Composer/Coordinator via closures on the ViewModel.
- If the user asks for a ViewModel for a clearly stateless subview, push back and ask whether they really need it.

## After creation

Print which files were created. If a ViewModel was created, remind the user that the Composer of `<Module>` should be updated to wire the new ViewModel — they can run `/update-composer <Module>` to audit it.
