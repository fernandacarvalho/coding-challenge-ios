# WorldPeek — Claude Code Project Guide

iOS app in Swift that lets users explore curious facts about every country in the world. Powered by the [REST Countries API](https://restcountries.com/v3.1/).

The Xcode project lives in `world-peek-ios/`. The rules below apply to all code in that subtree.

---

## Stack

- **Swift 5.9+**
- **SwiftUI** for UI
- **UIKit** (`UINavigationController` + `UIHostingController`) for navigation
- **async/await** for concurrency (no Combine)
- **SPM** for dependencies (avoid CocoaPods/Carthage)
- **Swift Testing** for tests (`import Testing`, `@Suite`, `@Test`, `#expect`) — never XCTest

---

## Domain

Per-country data shown in the app: `name`, `flag`, `continent`, `currency`, `population`, `bordering countries`.

v1 features:
- Search countries by name
- Filter by continent
- No local persistence (no CoreData/SwiftData)

API base URL: `https://restcountries.com/v3.1/`

---

## Architecture — feature-modular

Each feature lives in its own module under `Modules/`. A module is self-contained and exposes a single public entry point: its **Composer**.

```
world-peek-ios/world-peek-ios/
├── App/
│   ├── WorldPeekApp.swift          ← @main, sets up Window with UINavigationController root
│   ├── AppCoordinator.swift        ← orchestrates root navigation (push/present composers)
│   └── AppDependencies.swift       ← Composition Root: struct holding all global deps
│
├── Modules/
│   ├── CountrySearch/                          ← "full" module: has its own layers
│   │   ├── CountrySearchUIComposer.swift       ← make(...) -> (UIViewController, ViewModel)
│   │   ├── View/                               ← SwiftUI Views
│   │   ├── Presentation/                       ← ViewModels (@MainActor ObservableObject)
│   │   ├── Domain/                             ← only created if module owns logic
│   │   │   ├── Model/
│   │   │   ├── UseCases/
│   │   │   └── Repositories/                   ← protocols (contracts) exposed by the module
│   │   └── Data/                               ← only created if module owns repos/services
│   │       ├── Repositories/
│   │       └── Services/
│   │
│   └── CountryDetails/                         ← "thin" module: only consumes external deps
│       ├── CountryDetailsUIComposer.swift      ← receives getCountryDetailsUseCase via deps
│       ├── View/
│       └── Presentation/
│
└── Shared/                         ← truly cross-cutting code
    ├── Network/                    ← base HTTP client, error types
    ├── DesignSystem/               ← colors, typography, reusable components
    ├── Extensions/
    └── Testing/                    ← LeakTrackingTestSuite, makeTestDependencies, shared spies/fixtures
```

### Module isolation

- A module **never** imports another module's internal layers (Data, Presentation, View).
- The **only public entry point of a module is its Composer**.
- Cross-module communication happens via:
  - The **Composer** of the destination module (called by `AppCoordinator` or by another Composer)
  - **Protocols** exposed in the source module's `Domain`
  - **Models** from `Domain` (pure structs)
- `AppDependencies` is the only place that knows the concrete global implementations (HTTP client, shared repositories, analytics). **No singletons.**
- `Shared/` only contains genuinely cross-cutting code (base networking, design system) — never business rules.

### Folders are created on demand

A module starts with only `View/`, `Presentation/`, and the `Composer`. Domain/Data folders are created only when the module actually needs them. A thin module that consumes everything via `deps` may have just View + Presentation + Composer.

---

## Composition Root — `AppDependencies`

A single `struct AppDependencies` instantiated at `@main` holds all global app dependencies.

```swift
struct AppDependencies {
    let httpClient: HTTPClient
    let analytics: AnalyticsManaging
    // Add here only what is REALLY shared across multiple modules
}

extension AppDependencies {
    static func live() -> AppDependencies {
        AppDependencies(
            httpClient: URLSessionHTTPClient(session: .shared),
            analytics: ConsoleAnalytics()
        )
    }
}
```

Usage in `WorldPeekApp`:

```swift
@main
struct WorldPeekApp: App {
    let dependencies = AppDependencies.live()
    private let coordinator: AppCoordinator

    init() {
        coordinator = AppCoordinator(deps: dependencies)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
        }
    }
}
```

**Forbidden:**
- Swinject, Factory, swift-dependencies, or any DI library
- `DI.shared.resolve(...)` or any container singleton
- `AppDependencies.shared` or any other singleton-style accessor

---

## Composer pattern — required contract

Every module exposes a Composer with this exact shape:

```swift
enum CountrySearchUIComposer {
    static func make(
        // External dependencies (provided by the caller)
        deps: AppDependencies,
        onCountrySelected: @escaping (Country) -> Void
    ) -> (UIViewController, CountrySearchViewModel) {
        // 1) Build INTERNAL deps of the module (Service → Repository → UseCase)
        let service = CountrySearchServiceRemote(client: deps.httpClient)
        let repository = CountrySearchRepositoryImpl(service: service)
        let useCase = SearchCountriesUseCase(repository: repository)

        // 2) Build the ViewModel
        let viewModel = CountrySearchViewModel(
            searchCountriesUseCase: useCase,
            analytics: deps.analytics,
            onCountrySelected: onCountrySelected
        )

        // 3) Host the SwiftUI View in UIHostingController
        let rootView = CountrySearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)

        // 4) Return the tuple
        return (hostingController, viewModel)
    }
}
```

### Composer rules

- Always an `enum` with a `static func make(...)` — no state, no instance.
- First parameter: `deps: AppDependencies` (or a typed subset if the module needs only a few deps).
- Other parameters: only **external** dependencies (navigation callbacks, IDs from the previous route, preloaded data).
- Internal dependencies (UseCases/Repositories/Services owned by the module) are **never** parameters — they are instantiated inside the Composer.
- The Composer must **never** access singletons. If something is missing in `deps`, add it to `AppDependencies`.
- Return type is always `(UIViewController, ViewModel)`.
- ViewModels **must not** import UIKit or SwiftUI. They expose closures for navigation events; the Composer/Coordinator decides where to go.

---

## Navigation — UIKit-based

- `AppCoordinator` holds a reference to the root `UINavigationController`.
- When a ViewModel emits a navigation callback, the Coordinator calls the destination module's Composer and performs `pushViewController(_:animated:)` or `present(_:animated:)`.
- **Forbidden in SwiftUI:** `NavigationStack`, `NavigationLink`, `NavigationView`, `navigationDestination(for:)`. All navigation is UIKit-driven.
- ViewModels expose typed closures: `onCountrySelected: ((Country) -> Void)?`, `onClose: (() -> Void)?`. They never import UIKit.

---

## Code style — required

- **No force unwrap (`!`)** anywhere. Use optional chaining, `guard let`, `if let`, or default values.
- ViewModels are `@MainActor final class` conforming to `ObservableObject`, injected via `init` with protocols (for testability).
- **SwiftUI Views observe ViewModels via `@Published` properties**: every piece of state the View renders must be a `@Published` property on the ViewModel. The View binds to it through `@StateObject` (at the entry-point) or `@ObservedObject` (in subviews receiving an existing ViewModel). Do not bypass this with passthrough subjects, manual `objectWillChange.send()`, or computed properties on the View that read mutable state outside the observable graph.
- Use `[weak self]` in long-lived closures (Tasks, async UseCase callbacks) to prevent retain cycles.
- SwiftUI Views: extract a private subview when `body` exceeds ~40 lines.
- Use `final class` whenever inheritance is not needed.
- Prefer `async/await` over completion handlers.
- Use `private(set)` instead of fully writable public properties when possible — including for `@Published` properties (`@Published private(set) var ...`) so only the ViewModel mutates state.
- Naming: `UseCasing` suffix for use case protocols (`SearchCountriesUseCasing`), `Repository` for repository protocols, `Service` for service protocols.

---

## Testing — Swift Testing only

### Coverage requirements

| Type | Minimum coverage |
|---|---|
| Composer | `make_doesNotLeak` only (no logic → nothing else to test) |
| ViewModel | Each public behavior + leak tracking via `makeSUT` |
| UseCase | Each execution path + leak tracking |
| Repository | DTO → Entity mapping + error propagation + leak tracking |
| Service | Request building + response parsing + error propagation + leak tracking |

### Test folder structure mirrors the project

```
world-peek-iosTests/
├── App/
├── Modules/
│   └── CountrySearch/
│       ├── CountrySearchUIComposerTests.swift
│       ├── Presentation/
│       │   └── CountrySearchViewModelTests.swift
│       ├── Domain/UseCases/
│       │   └── SearchCountriesUseCaseTests.swift
│       ├── Data/
│       │   ├── Repositories/
│       │   │   └── CountrySearchRepositoryImplTests.swift
│       │   └── Services/
│       │       └── CountrySearchServiceRemoteTests.swift
│       ├── Spies/                  ← module-specific spies
│       └── Fixtures/               ← module-specific fixtures
└── Shared/
    └── Testing/
        ├── LeakTrackingTestSuite.swift   ← base class with trackForMemoryLeaks
        ├── Spies/                        ← spies for shared types (HTTPClient, Analytics)
        └── Fixtures/                     ← fixtures for shared types
```

### Leak tracking helper

`Shared/Testing/LeakTrackingTestSuite.swift`:

```swift
import Testing

class LeakTrackingTestSuite {

    private struct TrackedRef {
        weak var instance: AnyObject?
        let sourceLocation: SourceLocation
    }

    private var trackedRefs: [TrackedRef] = []

    deinit {
        for ref in trackedRefs {
            #expect(
                ref.instance == nil,
                "Instance leaked — potential retain cycle",
                sourceLocation: ref.sourceLocation
            )
        }
    }

    func trackForMemoryLeaks(
        _ instances: [AnyObject],
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        for instance in instances {
            trackedRefs.append(.init(instance: instance, sourceLocation: sourceLocation))
        }
    }
}
```

Each `@Test` in Swift Testing receives a fresh suite instance, so `deinit` runs after each test — strong refs local to the test body are released by then.

### `makeSUT` pattern (required for any test file with a non-trivial SUT)

- The `@Suite` is declared as `final class` and inherits from `LeakTrackingTestSuite`.
- `makeSUT` calls `trackForMemoryLeaks([...])` with SUT + relevant spies.
- `typealias SUT`, `struct Spies`, and `func makeSUT` live in a `private extension` at the bottom of the file.
- Tests do not need `weak var` or `do { }` blocks — leak verification happens automatically in the suite's `deinit`.

```swift
import Testing
@testable import WorldPeek

@Suite("CountrySearchViewModel")
final class CountrySearchViewModelTests: LeakTrackingTestSuite {

    @Test("when query is empty, does not call the use case")
    func search_withEmptyText_doesNotCallUseCase() async {
        let (sut, spies) = makeSUT()

        await sut.search(query: "")

        #expect(spies.searchUseCase.executeCallsCount == 0)
    }

    @Test("when query is valid, calls the use case with the query")
    func search_withValidText_callsUseCaseWithQuery() async {
        let (sut, spies) = makeSUT()

        await sut.search(query: "brazil")

        #expect(spies.searchUseCase.executeCallsCount == 1)
        #expect(spies.searchUseCase.executeReceivedQueries == ["brazil"])
    }
}

// MARK: - Test Infrastructure

private extension CountrySearchViewModelTests {

    typealias SUT = CountrySearchViewModel

    struct Spies {
        let searchUseCase: SearchCountriesUseCasingSpy
        let analytics: AnalyticsManagingSpy
    }

    func makeSUT() -> (SUT, Spies) {
        let searchUseCase = SearchCountriesUseCasingSpy()
        let analytics = AnalyticsManagingSpy()

        let sut = CountrySearchViewModel(
            searchCountriesUseCase: searchUseCase,
            analytics: analytics,
            onCountrySelected: { _ in }
        )

        trackForMemoryLeaks(
            [
                searchUseCase,
                analytics,
                sut,
            ]
        )

        return (sut, Spies(searchUseCase: searchUseCase, analytics: analytics))
    }
}
```

### Composer test (leak only)

Composers contain no logic, so the only test is the leak check:

```swift
import Testing
@testable import WorldPeek

@Suite("CountrySearchUIComposer")
final class CountrySearchUIComposerTests: LeakTrackingTestSuite {

    @Test("make() does not leak memory")
    func make_doesNotLeak() {
        let deps = AppDependencies.makeForTesting()
        let (controller, viewModel) = CountrySearchUIComposer.make(
            deps: deps,
            onCountrySelected: { _ in }
        )

        trackForMemoryLeaks([controller, viewModel])
    }
}
```

If a Composer has conditional logic, that is a red flag — refactor.

### Spy pattern

One spy per protocol, in `Tests/.../Spies/<Protocol>Spy.swift`:

```swift
final class SearchCountriesUseCasingSpy: SearchCountriesUseCasing {
    private(set) var executeCallsCount = 0
    private(set) var executeReceivedQueries: [String] = []
    var executeToBeReturned: Result<[Country], Error> = .success([])

    func execute(query: String) async throws -> [Country] {
        executeCallsCount += 1
        executeReceivedQueries.append(query)
        return try executeToBeReturned.get()
    }
}
```

Spy rules:
- `final class` (so `weak` references work for leak tracking).
- Conforms to the dependency's protocol.
- For each method: `<method>CallsCount`, `<method>Received<Param>` (or array of params if multiple calls), `<method>ToBeReturned`.
- Default value of `toBeReturned` should be the contract's "neutral" value (empty array, empty success, etc.).

### Fixture pattern

In `Tests/.../Fixtures/<Type>+Fixture.swift`:

```swift
import Foundation
@testable import WorldPeek

extension Country {
    static func fixture(
        id: String = "BR",
        name: String = "Brazil",
        continent: Continent = .southAmerica,
        currency: Currency = .fixture(),
        population: Int = 0,
        borders: [String] = []
    ) -> Country {
        .init(
            id: id,
            name: name,
            continent: continent,
            currency: currency,
            population: population,
            borders: borders
        )
    }
}
```

Fixture rules:
- `static func fixture(...)` in a separate extension on the type.
- **All parameters have defaults** — tests override only what matters.
- For nested types, chain fixtures (`.fixture()` as the default).
- Lives only in the test target, never in `Sources/`.

### Auto-create missing spies and fixtures

When generating tests (e.g. via `/test-module`), if a needed `<Protocol>Spy` or `<Type>+Fixture.swift` does not exist in the test target, **create it automatically** following the rules in `/new-spy` and `/new-fixture`. Do not pause to ask — the spy/fixture is a precondition for compiling the test. Print one line per auto-created file so the user sees what was generated.

### `@Test(arguments:)` for parameterized tests

Whenever the same behavior has variations (e.g. enum cases, boundary values), use a single parameterized test:

```swift
@Test(
    "formats title per continent",
    arguments: [
        (Continent.africa, "Africa"),
        (Continent.asia, "Asia"),
        (Continent.europe, "Europe"),
        (Continent.northAmerica, "North America"),
        (Continent.southAmerica, "South America"),
        (Continent.oceania, "Oceania"),
        (Continent.antarctica, "Antarctica")
    ]
)
func continentTitle(continent: Continent, expected: String) {
    #expect(continent.localizedTitle == expected)
}
```

Do not write N repeated tests for variations — use `arguments`.

---

## Slash commands

Custom commands available in `.claude/commands/`. They scaffold code that already conforms to the rules above:

- `/new-module <Name>` — create a new module with View + Presentation + Composer (no Domain/Data unless requested later)
- `/new-view <Module> <Name> [--with-viewmodel | --no-viewmodel]` — create a SwiftUI View, optionally with a ViewModel
- `/new-usecase <Module> <Name>` — create UseCase protocol + implementation in `<Module>/Domain/UseCases/`
- `/new-repository <Module> <Name>` — create Repository protocol + implementation + Service in the module
- `/update-composer <Module>` — audit and refactor an existing Composer against the contract
- `/test-module <Module>` — scaffold the test files (Composer leak test, ViewModel/UseCase/Repository/Service tests)
- `/new-spy <Protocol>` — generate a Spy class following the project pattern
- `/new-fixture <Type>` — generate a `static func fixture(...)` extension
- `/review-swift` — review the current file against all project rules

---

## Communication

The conversation may happen in Portuguese. **All generated artifacts (code, comments, docs, commit messages) must be written in English.**
