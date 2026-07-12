//
//  CountryDetailsViewModelTests.swift
//  world-peek-iosTests
//
//  Created by Fernanda Carvalho on 29/04/26.
//

import Foundation
import Testing
@testable import world_peek_ios

@Suite("CountryDetailsViewModel")
@MainActor
final class CountryDetailsViewModelTests: Test.WorldPeekTesting {
    @Test("toggleCard updates isExpanded property")
    func toggleCard_updateIsExpanded() async {
        let (sut, _) = makeSUT(country: Country.fixture())
        let initialState = sut.isCardExpanded
        
        sut.toggleCard()
        await Task.yield()
        
        #expect(sut.isCardExpanded != initialState)
    }
    
    @Test("searchForTickets opens Google Flights using capital")
        func searchForTickets_usesCapital() {
            let country = Country.fixture(
                name: "Brazil",
                capital: ["Brasilia"]
            )

            let (sut, _) = makeSUT(country: country)

            var capturedURL: URL?

            sut.onOpenURL = {
                capturedURL = $0
            }

            sut.searchForTickets()

            let expectedQuery = "Flights to Brasilia"
                .addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                )!

            let expectedURL = URL(
                string: "https://www.google.com/travel/flights?q=\(expectedQuery)"
            )

            #expect(capturedURL == expectedURL)
        }

        @Test("searchForTickets falls back to country name when capital is empty")
        func searchForTickets_fallbackToCountryName() {
            let country = Country.fixture(
                name: "Greece",
                capital: []
            )

            let (sut, _) = makeSUT(country: country)

            var capturedURL: URL?

            sut.onOpenURL = {
                capturedURL = $0
            }

            sut.searchForTickets()

            let expectedQuery = "Flights to Greece"
                .addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                )!

            let expectedURL = URL(
                string: "https://www.google.com/travel/flights?q=\(expectedQuery)"
            )

            #expect(capturedURL == expectedURL)
        }

        @Test("searchForTickets invokes onOpenURL")
        func searchForTickets_callsOnOpenURL() {
            let (sut, _) = makeSUT(
                country: Country.fixture()
            )

            var didOpenURL = false

            sut.onOpenURL = { _ in
                didOpenURL = true
            }

            sut.searchForTickets()

            #expect(didOpenURL)
        }

        @Test("searchForTickets encodes spaces in destination")
        func searchForTickets_encodesDestination() {
            let country = Country.fixture(
                name: "South Korea",
                capital: ["Seoul City"]
            )

            let (sut, _) = makeSUT(country: country)

            var capturedURL: URL?

            sut.onOpenURL = {
                capturedURL = $0
            }

            sut.searchForTickets()

            #expect(
                capturedURL?.absoluteString ==
                "https://www.google.com/travel/flights?q=Flights%20to%20Seoul%20City"
            )
        }
}

// MARK: - Test Infrastructure

private extension CountryDetailsViewModelTests {

    typealias SUT = CountryDetailsViewModel

    struct Spies {}

    func makeSUT(country: Country) -> (SUT, Spies) {
        let sut = CountryDetailsViewModel(country: country)

        trackForMemoryLeaks([sut])

        return (sut, .init())
    }
}
