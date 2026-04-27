---
description: Scaffold the unit test files for a module using Swift Testing, makeSUT, Spies, fixtures, and leak tracking
argument-hint: <Module>
---

Generate the unit test scaffold for module **$ARGUMENTS** under `world-peek-ios/world-peek-iosTests/Modules/$ARGUMENTS/`. Mirrors the source folder structure.

## Pre-flight checks

1. If `$ARGUMENTS` is empty, ask which module to scaffold tests for.
2. Verify that `world-peek-ios/world-peek-ios/Modules/$ARGUMENTS/` exists. If not, stop and suggest running `/new-module $ARGUMENTS`.
3. Inspect which layers actually exist in the module (the agent must read the source folders before generating tests):
   - `Modules/$ARGUMENTS/Presentation/` → ViewModel tests
   - `Modules/$ARGUMENTS/Domain/UseCases/` → UseCase tests
   - `Modules/$ARGUMENTS/Data/Repositories/` → Repository tests
   - `Modules/$ARGUMENTS/Data/Services/` → Service tests
4. Skip generating a test file when its corresponding source file does not exist. Do not create empty test stubs for layers the module does not own.
5. Verify `Shared/Testing/LeakTrackingTestSuite.swift` exists in the test target. If it does not, generate it first (see template below).

## Files to generate

Always generate these target paths (mirroring source structure under `world-peek-iosTests/Modules/$ARGUMENTS/`):

- `$ARGUMENTSUIComposerTests.swift` — composer leak test only
- `Presentation/<ViewModelName>Tests.swift` — for each ViewModel found in `Modules/$ARGUMENTS/Presentation/`
- `Domain/UseCases/<UseCaseName>Tests.swift` — for each UseCase found in `Modules/$ARGUMENTS/Domain/UseCases/`
- `Data/Repositories/<RepositoryName>ImplTests.swift` — for each Repository implementation
- `Data/Services/<ServiceName>RemoteTests.swift` — for each Service remote implementation

## Templates

### LeakTrackingTestSuite (generate once, in `Shared/Testing/LeakTrackingTestSuite.swift` of the test target)

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

### Composer test — leak only

```swift
import Testing
@testable import world_peek_ios

@Suite("$ARGUMENTSUIComposer")
final class $ARGUMENTSUIComposerTests: LeakTrackingTestSuite {

    @Test("make() does not leak memory")
    func make_doesNotLeak() {
        let deps = AppDependencies.makeForTesting()
        let (controller, viewModel) = $ARGUMENTSUIComposer.make(
            deps: deps
            // TODO: pass any external dependencies the composer requires
        )

        trackForMemoryLeaks([controller, viewModel])
    }
}
```

> Composers contain no logic by contract. Do **not** add any other test to a Composer test file. If a Composer has logic, that's a refactoring signal, not a testing signal.

### ViewModel / UseCase / Repository / Service template

Use this exact shape, adapting the names and dependencies. The `private extension` lives at the bottom.

```swift
import Testing
@testable import world_peek_ios

@Suite("<TypeName>")
final class <TypeName>Tests: LeakTrackingTestSuite {

    @Test("describes the behavior under test")
    func behavior_underCondition_producesExpectedOutcome() async throws {
        let (sut, spies) = makeSUT()

        // Arrange: configure spies via spies.<dependency>.<methodName>ToBeReturned
        // Act: call the SUT
        // Assert with #expect using spies counters / received args

        #expect(spies.<dependency>.<methodName>CallsCount == 1)
    }
}

// MARK: - Test Infrastructure

private extension <TypeName>Tests {

    typealias SUT = <TypeName>

    struct Spies {
        let <dependency>: <DependencyProtocol>Spy
        // add one entry per collaborator the tests need to inspect
    }

    func makeSUT() -> (SUT, Spies) {
        let <dependency> = <DependencyProtocol>Spy()
        // ... build other spies

        let sut = <TypeName>(
            <dependencyParameter>: <dependency>
            // ... pass remaining init parameters
        )

        trackForMemoryLeaks(
            [
                <dependency>,
                sut,
                // ... add every spy that supports `weak` and the SUT
            ]
        )

        return (sut, Spies(<dependency>: <dependency>))
    }
}
```

## Auto-create missing test infrastructure

Before writing any test file, identify every spy and fixture the new tests will reference. Then, for each one that does not already exist in the test target, **create it automatically by following the same rules as `/new-spy` and `/new-fixture`**:

1. Scan the test target for an existing `<Protocol>Spy` or `<Type>+Fixture.swift`.
2. If absent, generate it inline using the templates documented in `.claude/commands/new-spy.md` and `.claude/commands/new-fixture.md`. Place it under the correct folder (`<TestModule>/Spies/`, `<TestModule>/Fixtures/`, or `Shared/Testing/Spies|Fixtures/`).
3. Print one line per file auto-created so the user sees what happened.

Do not stop the test scaffold to ask the user — the spy/fixture is a precondition. Only ask if the protocol/type itself cannot be located in the source tree.

## Rules to enforce while generating

- `import Testing` (never `import XCTest`).
- `@Suite final class <Name>: LeakTrackingTestSuite` (never `struct`, never an XCTest subclass).
- `typealias SUT`, `struct Spies`, and `func makeSUT() -> (SUT, Spies)` go in a `private extension <NameOfTests>` at the bottom of the file.
- `trackForMemoryLeaks([sut, ...spies])` is always called inside `makeSUT`, with the SUT as the last item.
- Use `@Test(arguments:)` for variations of the same behavior (e.g. enum cases) — never write N near-duplicate tests.
- Use fixtures (`Type.fixture(...)`) instead of literal struct construction. If a fixture is missing, **auto-create it** following `/new-fixture` rules (see "Auto-create missing test infrastructure" above).
- Use spies (`<Protocol>Spy`) instead of inline mock classes. If a spy is missing, **auto-create it** following `/new-spy` rules.
- For Repository tests: cover DTO → Entity mapping and error propagation.
- For Service tests: cover request building (URL, method, headers, body), response parsing, and error propagation.

## After generation

Print a summary in two sections:
1. **Test files generated** — one per layer found (with paths).
2. **Test infrastructure auto-created** — list of spies and fixtures created on the fly, with paths.
3. **Skipped layers** — layers whose source files do not exist in the module (so no test was generated).
