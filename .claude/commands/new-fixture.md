---
description: Generate a static fixture(...) factory extension for a domain type, with sensible defaults
argument-hint: <TypeName>
---

Generate a fixture extension for the type named `$ARGUMENTS`.

## Pre-flight checks

1. If `$ARGUMENTS` is empty, ask which type to create a fixture for.
2. Locate the type declaration under `world-peek-ios/world-peek-ios/...`. Read it to know:
   - All stored properties (name + type)
   - Whether it is a `struct`, `enum`, or `class`
   - Whether properties have explicit defaults already
3. Decide where the fixture lives:
   - If the type belongs to a specific module's `Domain/Model/`, place the fixture at `world-peek-ios/world-peek-iosTests/Modules/<Module>/Fixtures/$ARGUMENTS+Fixture.swift`.
   - If the type is shared, place it at `world-peek-ios/world-peek-iosTests/Shared/Testing/Fixtures/$ARGUMENTS+Fixture.swift`.
   - Create the `Fixtures/` folder if it does not exist.
4. Verify the fixture file does not already exist.

## Fixture template — required pattern

The fixture is a `static func fixture(...)` in an extension on the type. EVERY parameter must have a default. Tests override only what matters.

### Defaults to use, by Swift type

- `String`: `""`
- `Int`, `Double`, `Float`: `0`
- `Bool`: `false`
- `[T]`: `[]`
- `[K: V]`: `[:]`
- `Optional<T>`: `nil`
- `Date`: `.now`
- `URL`: `URL(string: "https://example.com")!` — but do not use force unwrap; prefer `URL(string: "https://example.com") ?? URL(fileURLWithPath: "/")`
- `UUID`: `.init()` (or a deterministic UUID if the test target needs one)
- Custom enums: the first declared case (or a "default" case if one exists)
- Custom types with their own fixture: `.fixture()` (chain fixtures so callers can compose deep graphs without specifying every field)
- Closures: `{ _ in }` or the no-op equivalent
- Currency, money, etc.: `.zero` if available

### Example — given:

```swift
struct Country {
    let id: String
    let name: String
    let continent: Continent
    let currency: Currency
    let population: Int
    let borders: [String]
}
```

### Generated fixture:

```swift
import Foundation
@testable import world_peek_ios

extension Country {
    static func fixture(
        id: String = "",
        name: String = "",
        continent: Continent = .africa,
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

## Rules to enforce

- The fixture is a `static func fixture(...)` inside an `extension` (one extension per file, one fixture per type).
- All parameters MUST have defaults.
- Use `@testable import world_peek_ios` so the fixture can construct types with `internal` initializers.
- For nested types that already have a fixture, default to `.fixture()` (do not duplicate field defaults).
- Do not place fixtures inside `world-peek-ios/world-peek-ios/` (production target) — they belong to the test target only.
- Never use force unwrap (`!`) inside default values.

## After generation

Confirm the file path created and remind the user that:
- This fixture can now be used in `makeSUT`, in spy stubs (`<Method>ToBeReturned = .success([.fixture()])`), and inside `#expect` arrange blocks.
- Other types referenced by this one may also need fixtures — suggest running `/new-fixture <Type>` for each.
