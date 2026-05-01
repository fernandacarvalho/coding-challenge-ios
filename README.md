# WorldPeek

iOS app for exploring informations about every country in the world, powered by the [REST Countries API](https://restcountries.com/v3.1/).

## Features

- Search countries by name; filter by continent
- Country detail page: flag, region, capital, population, currencies, languages, and bordering countries
- Interactive map (MapKit) centered on the selected country
- One-tap link to [Google Flights](https://www.google.com/travel/flights) for the selected country
- Continent-level response cache for reduced network usage
- Localized in English and Portuguese (pt-BR)
- Light and dark mode

## Stack

- Swift 5.9+ / iOS 17.6+
- SwiftUI (views) + UIKit (navigation via `UINavigationController` + `UIHostingController`)
- `async/await` — no Combine
- Swift Package Manager
- MapKit
- [Kingfisher](https://github.com/onevcat/Kingfisher) — remote image loading
- [CollectionConcurrencyKit](https://github.com/JohnSundell/CollectionConcurrencyKit) — async collection operations
- [SwiftLint](https://github.com/realm/SwiftLint) — lint (dev only, via SPM plugin)
- [Swift Testing](https://github.com/apple/swift-testing) — test framework

## Architecture

The project is feature-modular. Each feature lives under `Modules/` and exposes a single public entry point: an `enum *UIComposer` with a `static func make(deps:...) -> (UIViewController, ViewModel)`. Internal layers (UseCase, Repository, Service) are instantiated inside the Composer and are never exposed.

`AppDependencies` is the composition root — a plain struct instantiated at `@main` and threaded through the app. No DI containers, no singletons. Navigation is orchestrated by `AppCoordinator` over a root `UINavigationController`; SwiftUI views never use `NavigationStack` or `NavigationLink`.

See [CLAUDE.md](CLAUDE.md) for the full architectural contract, module isolation rules, and code style requirements.

## Caching

Country data is cached per continent as JSON on disk under `FileManager.cachesDirectory/countries/{continent}.json`. Each cache entry wraps the payload with a timestamp; a cached continent is considered fresh for 24 hours. On subsequent loads within that window, the network request is skipped entirely. Cache reads and writes are best-effort — any failure is silently ignored and falls back to the network.

## Localization and appearance

Strings are managed via `Localizable.xcstrings` (String Catalogs). Supported locales: `en` (source), `pt-BR`. All colors are defined in the asset catalog with explicit light and dark variants, so the app adapts to the system appearance automatically without any manual color-scheme checks.

## Requirements

- Xcode 16+ (iOS 17.6 SDK)
- macOS with Homebrew
- SwiftLint: `brew install swiftlint`

## Getting started

```bash
git clone <repo-url>
cd ifood-ios-test

# Wire the git hooks (run once per clone)
make setup

# Install SwiftLint if you haven't already
brew install swiftlint
```

Then open `world-peek-ios/world-peek-ios.xcodeproj` in Xcode and build/run on any iOS 17.6+ simulator or device.

## Git hooks

`make setup` sets `core.hooksPath` to `.githooks/` and marks the hook executable. The `pre-commit` hook runs SwiftLint against all staged `.swift` files using the project's `.swiftlint.yml` config; the commit is blocked if any violation is found.

```bash
make lint           # run lint manually against the full project
git commit --no-verify  # bypass the hook (not recommended)
```

If SwiftLint is not installed, the hook prints a warning and exits without blocking.

## Testing

Run the test suite with `Cmd+U` in Xcode or via `xcodebuild test`.

Tests use Swift Testing (`@Suite`, `@Test`, `#expect`) exclusively — no XCTest. The base class `LeakTrackingTestSuite` verifies memory leaks automatically in `deinit` after each test. Each test file follows the `makeSUT` / Spies / Fixtures pattern: Spies are `final class` types conforming to a protocol, Fixtures are `static func fixture(...)` extensions with defaulted parameters.

## Project layout

```
world-peek-ios/
├── world-peek-ios/
│   ├── App/
│   │   ├── WorldPeekApp.swift
│   │   ├── AppCoordinator.swift
│   │   └── AppDependencies.swift
│   ├── Modules/
│   │   ├── CountrySearch/          # search + continent filter
│   │   ├── CountryDetails/         # detail page + map + flights link
│   │   └── FlightSearch/           # Google Flights in-app browser
│   └── Shared/
│       ├── Network/
│       ├── DesignSystem/
│       ├── Persistence/            # cache configuration
│       └── Extensions/
└── world-peek-iosTests/            # mirrors source structure
    ├── Modules/
    └── Shared/
        └── Testing/                # LeakTrackingTestSuite, shared Spies/Fixtures
```
