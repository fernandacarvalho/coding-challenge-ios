---
description: Create a UseCase protocol and implementation inside a module's Domain/UseCases folder
argument-hint: <Module> <UseCaseName>
---

Create a new UseCase inside the module's Domain layer.

Arguments: `$ARGUMENTS`

## Argument parsing

Parse `$ARGUMENTS` as: `<Module> <UseCaseName>`

- If fewer than two tokens, ask for the missing pieces.
- The UseCase name should follow the convention `<Verb><Noun>UseCase` (e.g. `SearchCountriesUseCase`, `GetCountryDetailsUseCase`).

## Pre-flight checks

1. Verify that `world-peek-ios/world-peek-ios/Modules/<Module>/` exists. If not, stop and suggest running `/new-module <Module>` first.
2. Create the folder `Modules/<Module>/Domain/UseCases/` if it does not exist (this is the moment the Domain layer comes into existence — do not create it any earlier).
3. Verify that `<UseCaseName>.swift` does not already exist in that folder.

## What to create

### `Modules/<Module>/Domain/UseCases/<UseCaseName>.swift`

```swift
import Foundation

protocol <UseCaseName>ing {
    // TODO: define the method signature.
    // Prefer async throws when the use case performs I/O.
    // Example:
    // func execute(query: String) async throws -> [Country]
}

final class <UseCaseName>: <UseCaseName>ing {
    // TODO: inject dependencies via init using protocols.
    // Example:
    // private let repository: CountrySearchRepository
    //
    // init(repository: CountrySearchRepository) {
    //     self.repository = repository
    // }

    // TODO: implement the protocol method
}
```

## Rules to enforce

- Protocol name uses the `ing` suffix: `<UseCaseName>ing` (e.g. `SearchCountriesUseCasing`).
- The concrete implementation is a `final class`.
- All dependencies are injected via `init` using protocols (so they can be replaced by spies in tests).
- The UseCase file lives in `Domain/UseCases/`, not `Data/`.
- Do not access global singletons or `AppDependencies` directly inside the UseCase.

## After creation

Remind the user that the Composer of `<Module>` likely needs to instantiate this UseCase and pass it to the ViewModel. Suggest running `/update-composer <Module>` to audit the wiring, and `/test-module <Module>` (or `/new-spy <UseCaseName>ing`) to scaffold the corresponding tests.
