import Testing
@testable import world_peek_ios

@Suite("CountrySearchUIComposer")
@MainActor
final class CountrySearchUIComposerTests: Test.WorldPeekTesting {

    @Test("make() does not leak memory")
    func make_doesNotLeak() {
        let deps = AppDependencies.makeForTesting()
        let (controller, viewModel) = CountrySearchUIComposer.make(deps: deps)

        trackForMemoryLeaks([controller, viewModel])
    }
}
