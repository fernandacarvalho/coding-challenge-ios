import Testing
@testable import world_peek_ios

@Suite("CountrySearchRepository")
final class CountrySearchRepositoryTests: Test.WorldPeekTesting {

    // MARK: - Service delegation

    @Test(
        "fetchCountries delegates to service with continent rawValue as region",
        arguments: Continent.allCases
    )
    func fetchCountries_callsServiceWithContinentRawValue(continent: Continent) async throws {
        let (sut, spies) = makeSUT()

        _ = try await sut.fetchCountries(for: continent)

        #expect(spies.service.fetchCountriesCallsCount == 1)
        #expect(spies.service.fetchCountriesReceivedRegions == [continent.rawValue])
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

    @Test("fetchCountries propagates service error")
    func fetchCountries_propagatesServiceError() async {
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success([])
        spies.service.fetchCountriesToBeReturned = .failure(HTTPClientError.serverError(statusCode: 500))

        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchCountries(for: .oceania)
        }
    }

    // MARK: - Cache hit

    @Test("fetchCountries when cache returns countries does not call service")
    func fetchCountries_whenCacheHit_doesNotCallService() async throws {
        let cached = [Country.fixture()]
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success(cached)

        let result = try await sut.fetchCountries(for: .africa)

        #expect(spies.service.fetchCountriesCallsCount == 0)
        #expect(result == cached)
    }

    @Test("fetchCountries when cache returns countries does not save to cache")
    func fetchCountries_whenCacheHit_doesNotSaveToCache() async throws {
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success([Country.fixture()])

        _ = try await sut.fetchCountries(for: .africa)

        #expect(spies.cacheStore.saveCallsCount == 0)
    }

    // MARK: - Cache miss

    @Test("fetchCountries when cache is empty calls service")
    func fetchCountries_whenCacheMiss_callsService() async throws {
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success([])
        spies.service.fetchCountriesToBeReturned = .success([CountryDTO.fixture()])

        _ = try await sut.fetchCountries(for: .africa)

        #expect(spies.service.fetchCountriesCallsCount == 1)
    }

    @Test("fetchCountries when cache is empty saves fetched countries to cache")
    func fetchCountries_whenCacheMiss_savesCountriesToCache() async throws {
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success([])
        spies.service.fetchCountriesToBeReturned = .success([CountryDTO.fixture()])

        _ = try await sut.fetchCountries(for: .africa)

        #expect(spies.cacheStore.saveCallsCount == 1)
        #expect(spies.cacheStore.saveReceivedContinents == [.africa])
    }

    @Test("fetchCountries when service fails does not save to cache")
    func fetchCountries_whenServiceFails_doesNotSaveToCache() async throws {
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success([])
        spies.service.fetchCountriesToBeReturned = .failure(HTTPClientError.serverError(statusCode: 500))

        _ = try? await sut.fetchCountries(for: .africa)

        #expect(spies.cacheStore.saveCallsCount == 0)
    }

    @Test("fetchCountries calls service for each distinct continent on cache miss")
    func fetchCountries_differentContinents_callsServiceForEach() async throws {
        let (sut, spies) = makeSUT()
        spies.cacheStore.fetchToBeReturned = .success([])
        spies.service.fetchCountriesToBeReturned = .success([CountryDTO.fixture()])

        _ = try await sut.fetchCountries(for: .africa)
        _ = try await sut.fetchCountries(for: .asia)

        #expect(spies.service.fetchCountriesCallsCount == 2)
    }
}

// MARK: - Test Infrastructure

private extension CountrySearchRepositoryTests {

    typealias SUT = CountrySearchRepository

    struct Spies {
        let service: CountrySearchServiceSpy
        let cacheStore: CountryCacheStoringSpy
    }

    func makeSUT(cacheConfiguration: CacheConfiguration = .testing) -> (SUT, Spies) {
        let service = CountrySearchServiceSpy()
        let cacheStore = CountryCacheStoringSpy()

        let sut = CountrySearchRepository(
            service: service,
            cacheStore: cacheStore,
            cacheConfiguration: cacheConfiguration
        )

        trackForMemoryLeaks([service, cacheStore, sut])

        return (sut, Spies(service: service, cacheStore: cacheStore))
    }
}
