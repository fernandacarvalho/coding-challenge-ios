---
description: Create a Repository protocol, its implementation, and the corresponding Service inside a module
argument-hint: <Module> <RepositoryName>
---

Create a new Repository inside the module: protocol in `Domain/Repositories/`, implementation in `Data/Repositories/`, and a corresponding Service in `Data/Services/`.

Arguments: `$ARGUMENTS`

## Argument parsing

Parse `$ARGUMENTS` as: `<Module> <RepositoryName>`

- If fewer than two tokens, ask for the missing pieces.
- The Repository name should follow the convention `<Domain>Repository` (e.g. `CountrySearchRepository`, `CountryDetailsRepository`).

## Pre-flight checks

1. Verify that `world-peek-ios/world-peek-ios/Modules/<Module>/` exists. If not, stop and suggest running `/new-module <Module>` first.
2. **Confirm before creating**: if the Composer of `<Module>` already receives a repository protocol via `deps` or a parameter, ask the user whether they really want a module-internal repository, since duplicating one is a common mistake. Only proceed after explicit confirmation.
3. Create the folders if they do not exist:
   - `Modules/<Module>/Domain/Repositories/`
   - `Modules/<Module>/Data/Repositories/`
   - `Modules/<Module>/Data/Services/`
4. Verify that none of the target files already exist.

## What to create

### 1. `Modules/<Module>/Domain/Repositories/<RepositoryName>.swift`

```swift
import Foundation

protocol <RepositoryName> {
    // TODO: define methods using async throws when performing I/O.
    // Repository methods return DOMAIN entities, never DTOs.
    // Example:
    // func search(query: String) async throws -> [Country]
}
```

### 2. `Modules/<Module>/Data/Repositories/<RepositoryName>Impl.swift`

```swift
import Foundation

final class <RepositoryName>Impl: <RepositoryName> {
    private let service: <RepositoryName>Service

    init(service: <RepositoryName>Service) {
        self.service = service
    }

    // TODO: implement the protocol methods.
    // This is the place to map DTOs (from the Service) into Domain entities.
}
```

### 3. `Modules/<Module>/Data/Services/<RepositoryName>Service.swift`

```swift
import Foundation

protocol <RepositoryName>Service {
    // TODO: declare service methods that return DTOs (Codable structs that mirror the API response).
    // Example:
    // func fetch(query: String) async throws -> [CountryDTO]
}

final class <RepositoryName>ServiceRemote: <RepositoryName>Service {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    // TODO: implement service methods.
    // Build URLRequests, decode JSON into DTOs, propagate errors.
}
```

## Rules to enforce

- Repository protocol lives in `Domain/Repositories/`. Repository implementation lives in `Data/Repositories/`.
- The implementation is `final class <RepositoryName>Impl` and conforms to the protocol.
- The Service protocol + remote implementation live in `Data/Services/`.
- Service returns DTOs (Codable). Repository maps DTOs → Domain entities. Never expose DTOs outside `Data/`.
- DTOs are private to the Service file (or in a sibling `DTOs/` folder if there are many).
- Do not access singletons or `AppDependencies` inside the Repository or Service. They receive their collaborators via `init`.

## After creation

Remind the user that:
- The Composer of `<Module>` must instantiate `<RepositoryName>ServiceRemote(client: deps.httpClient)`, then `<RepositoryName>Impl(service:)`, then inject the Repository (or a UseCase that depends on it) into the ViewModel.
- `/update-composer <Module>` can audit and update the wiring.
- `/test-module <Module>` will scaffold tests for both the Repository (mapping + error propagation) and the Service (request building + parsing).
