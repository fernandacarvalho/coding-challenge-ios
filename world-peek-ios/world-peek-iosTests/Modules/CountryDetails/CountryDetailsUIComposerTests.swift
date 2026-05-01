import Testing
import UIKit
@testable import world_peek_ios

@Suite("CountryDetailsUIComposer")
final class CountryDetailsUIComposerTests: Test.MoisesTesting {

    @Test("make() does not leak memory")
    @MainActor
    func make_doesNotLeak() {
        let deps = AppDependencies.makeForTesting()
        let (controller, viewModel) = CountryDetailsUIComposer.make(
            deps: deps,
            country: .fixture()
        )

        trackForMemoryLeaks([controller, viewModel])
    }
}
