---
description: Generate a Spy class for a protocol, following the project's spy pattern (callsCount, toBeReturned, captured args)
argument-hint: <ProtocolName>
---

Generate a Spy class for the protocol named `$ARGUMENTS`.

## Pre-flight checks

1. If `$ARGUMENTS` is empty, ask which protocol to spy.
2. Locate the protocol declaration in the source tree (`world-peek-ios/world-peek-ios/...`). Read it to know:
   - Each method signature (name, parameters, return type, `async`/`throws` markers)
   - Each property (read-only or read/write)
3. Decide where the spy should live:
   - If the protocol belongs to a specific module, place the spy at `world-peek-ios/world-peek-iosTests/Modules/<Module>/Spies/$ARGUMENTSSpy.swift`.
   - If the protocol is shared (e.g. `HTTPClient`, `AnalyticsManaging`), place it at `world-peek-ios/world-peek-iosTests/Shared/Testing/Spies/$ARGUMENTSSpy.swift`.
   - Create the `Spies/` folder if it does not exist.
4. Verify the spy file does not already exist.

## Spy template — required pattern

For each method on the protocol, the spy MUST expose:

- `private(set) var <method>CallsCount: Int = 0`
- One captured-args property per parameter:
  - For methods called once: `private(set) var <method>Received<Param>: <Type>?`
  - For methods called repeatedly: `private(set) var <method>Received<Param>s: [<Type>] = []` (use this when the test asserts the sequence of calls)
- `var <method>ToBeReturned: <ReturnType> = <neutral default>` (only if the method has a return value)
- For `throws` methods, prefer `var <method>ToBeReturned: Result<<ReturnType>, Error> = .success(<neutral>)` so tests can stub failures.

For each get-only property on the protocol:

- `var <property>ToBeReturned: <Type> = <neutral default>` and conform via `var <property>: <Type> { <property>ToBeReturned }`.

The spy itself must be a `final class` so leak tracking can hold it via `weak`.

### Example — given:

```swift
protocol SearchCountriesUseCasing {
    func execute(query: String) async throws -> [Country]
}
```

### Generated spy:

```swift
import Foundation
@testable import world_peek_ios

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

## Rules to enforce

- The class must be `final`.
- All counter and captured-arg properties use `private(set)` so tests can read but cannot mutate.
- Method bodies must, in order: increment the counter, capture parameters, return/throw the stubbed value.
- Default value of `toBeReturned` must be the contract's "neutral" value: empty array, `.success(())` for `Void`, `nil` for optionals, etc.
- Do not add behavior beyond recording calls and returning stubs — spies are dumb by design.

## After generation

Confirm the file path created and remind the user that this spy can now be used inside the `makeSUT` of any test file under `world-peek-iosTests/`.
