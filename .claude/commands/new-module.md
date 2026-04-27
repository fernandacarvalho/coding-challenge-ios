---
description: Scaffold a new feature module with View, Presentation, and Composer (no Domain/Data unless requested)
argument-hint: <ModuleName>
---

Scaffold a new feature module named **$ARGUMENTS** under `world-peek-ios/world-peek-ios/Modules/`.

## Pre-flight checks

1. If `$ARGUMENTS` is empty, ask for the module name.
2. If `Modules/$ARGUMENTS/` already exists, stop and report it. Do not overwrite.
3. Confirm the user wants only the minimum scaffold (View + Presentation + Composer). Do **not** create `Domain/` or `Data/` upfront — those folders are added later by `/new-usecase` and `/new-repository` only when actually needed.

## What to create

Create exactly these files:

### 1. `Modules/$ARGUMENTS/View/$ARGUMENTSView.swift`
```swift
import SwiftUI

struct $ARGUMENTSView: View {
    @StateObject var viewModel: $ARGUMENTSViewModel

    var body: some View {
        // TODO: implement
        Text("$ARGUMENTS")
    }
}
```

### 2. `Modules/$ARGUMENTS/Presentation/$ARGUMENTSViewModel.swift`
```swift
import Foundation

@MainActor
final class $ARGUMENTSViewModel: ObservableObject {
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

### 3. `Modules/$ARGUMENTS/$ARGUMENTSUIComposer.swift`
```swift
import UIKit
import SwiftUI

enum $ARGUMENTSUIComposer {
    static func make(
        deps: AppDependencies
        // TODO: add external dependencies (navigation callbacks, IDs, preloaded data)
    ) -> (UIViewController, $ARGUMENTSViewModel) {
        // 1) Build INTERNAL deps of the module here (Service → Repository → UseCase)
        //    using deps.* as the source for global dependencies.

        // 2) Build the ViewModel
        let viewModel = $ARGUMENTSViewModel()

        // 3) Host the SwiftUI View
        let rootView = $ARGUMENTSView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)

        // 4) Return the tuple
        return (hostingController, viewModel)
    }
}
```

## Rules to enforce

- Use the exact folder layout above. Do **not** create `Domain/`, `Data/`, `Spies/`, or any other folder.
- The Composer must be an `enum` with a single `static func make`.
- The first parameter of `make` must be `deps: AppDependencies`.
- The Composer must return `(UIViewController, $ARGUMENTSViewModel)`.
- `UIHostingController` must wrap the SwiftUI View.
- The ViewModel file must not import `UIKit` or `SwiftUI`.
- Any state the View reads from the ViewModel must be a `@Published` property (typically `@Published private(set) var ...`). Computed properties that derive from `@Published` state are allowed.

## After creation

Print a short summary of the files created and remind the user that:
- They can add Domain/UseCases via `/new-usecase $ARGUMENTS <UseCaseName>`
- They can add Repository + Data via `/new-repository $ARGUMENTS <RepositoryName>`
- They can scaffold tests via `/test-module $ARGUMENTS`
