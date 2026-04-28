import Testing
@testable import world_peek_ios

@Suite("CountrySearchRepository")
final class CountrySearchRepositoryTests: Test.MoisesTesting {

    @Test(
        "fetchCountries delegates to service with continent rawValue as region",
        arguments: Continent.allCases
    )
    func fetchCountries_callsServiceWithContinentRawValue(region: Continent) async throws {
        let (sut, spies) = makeSUT()

        _ = try await sut.fetchCountries(for: region)

        #expect(spies.service.fetchCountriesCallsCount == 1)
        #expect(spies.service.fetchCountriesReceivedRegions == [region.rawValue])
    }

    @Test("fetchCountries maps DTO to domain entity")
    func fetchCountries_mapsDTOtoDomain() async throws {
        let dto = CountryDTO.fixture()
        let (sut, spies) = makeSUT()
        spies.service.fetchCountriesToBeReturned = .success([dto])

        let result = try await sut.fetchCountries(for: .americas)

        #expect(result.count == 1)
        #expect(result[0].name == dto.name.common)
        #expect(result[0].region == dto.region)
    }

    @Test("fetchCountries caches result and does not call service again for same continent")
    func fetchCountries_cachesResult_skipsServiceOnSecondCall() async throws {
        let (sut, spies) = makeSUT()
        spies.service.fetchCountriesToBeReturned = .success([CountryDTO.fixture()])

        _ = try await sut.fetchCountries(for: .africa)
        _ = try await sut.fetchCountries(for: .africa)

        #expect(spies.service.fetchCountriesCallsCount == 1)
    }

    @Test("fetchCountries calls service for each distinct continent")
    func fetchCountries_differentContinents_callsServiceForEach() async throws {
        let (sut, spies) = makeSUT()
        spies.service.fetchCountriesToBeReturned = .success([CountryDTO.fixture()])

        _ = try await sut.fetchCountries(for: .africa)
        _ = try await sut.fetchCountries(for: .asia)

        #expect(spies.service.fetchCountriesCallsCount == 2)
    }

    @Test("fetchCountries propagates service error")
    func fetchCountries_propagatesServiceError() async {
        let (sut, spies) = makeSUT()
        spies.service.fetchCountriesToBeReturned = .failure(HTTPClientError.serverError(statusCode: 500))

        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchCountries(for: .oceania)
        }
    }
}

// MARK: - Test Infrastructure

private extension CountrySearchRepositoryTests {

    typealias SUT = CountrySearchRepository

    struct Spies {
        let service: CountrySearchServiceSpy
    }

    func makeSUT() -> (SUT, Spies) {
        let service = CountrySearchServiceSpy()
        let sut = CountrySearchRepository(service: service)

        trackForMemoryLeaks([service, sut])

        return (sut, Spies(service: service))
    }
}
