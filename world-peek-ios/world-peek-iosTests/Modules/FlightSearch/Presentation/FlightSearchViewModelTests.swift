import Foundation
import Testing
@testable import world_peek_ios

@Suite("FlightSearchViewModel")
@MainActor
final class FlightSearchViewModelTests: Test.WorldPeekTesting {

    @Test("init stores the provided URL")
    func init_storesURL() {
        let url = URL(string: "https://www.google.com/travel/flights?q=Flights%20to%20Paris")!
        let (sut, _) = makeSUT(url: url)

        #expect(sut.url == url)
    }
}

// MARK: - Test Infrastructure

private extension FlightSearchViewModelTests {

    typealias SUT = FlightSearchViewModel

    struct Spies {}

    func makeSUT(url: URL) -> (SUT, Spies) {
        let sut = FlightSearchViewModel(url: url)
        trackForMemoryLeaks([sut])
        return (sut, .init())
    }
}
