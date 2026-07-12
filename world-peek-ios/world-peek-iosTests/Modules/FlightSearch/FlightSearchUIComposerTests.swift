import Testing
import UIKit
@testable import world_peek_ios

@Suite("FlightSearchUIComposer")
final class FlightSearchUIComposerTests: Test.WorldPeekTesting {

    @Test("make() does not leak memory")
    @MainActor
    func make_doesNotLeak() {
        let deps = AppDependencies.makeForTesting()
        let url = URL(string: "https://www.google.com/travel/flights")!
        let (controller, viewModel) = FlightSearchUIComposer.make(
            deps: deps,
            url: url
        )

        trackForMemoryLeaks([controller, viewModel])
    }
}
