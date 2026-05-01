import Testing
import Foundation
@testable import world_peek_ios

@Suite("CountryCacheStore")
final class CountryCacheStoreTests: Test.MoisesTesting {

    @Test("fetch when no file exists returns empty array")
    func fetch_whenNoFile_returnsEmpty() async throws {
        let sut = makeSUT()

        let result = try await sut.fetchCountries(for: .americas, ttl: 3600)

        #expect(result.isEmpty)
    }

    @Test("save then fetch within TTL returns saved countries")
    func save_thenFetchWithinTTL_returnsSavedCountries() async throws {
        let sut = makeSUT()
        let countries = [Country.fixture()]

        try await sut.save(countries: countries, for: .americas)
        let result = try await sut.fetchCountries(for: .americas, ttl: 3600)

        #expect(result == countries)
    }

    @Test("fetch with expired TTL returns empty array")
    func fetch_withExpiredTTL_returnsEmpty() async throws {
        let sut = makeSUT()
        try await sut.save(countries: [Country.fixture()], for: .americas)

        let result = try await sut.fetchCountries(for: .americas, ttl: -1)

        #expect(result.isEmpty)
    }

    @Test("save for one continent does not affect another continent")
    func save_forOneContinent_doesNotAffectAnotherContinent() async throws {
        let sut = makeSUT()
        try await sut.save(countries: [Country.fixture()], for: .americas)

        let result = try await sut.fetchCountries(for: .africa, ttl: 3600)

        #expect(result.isEmpty)
    }

    @Test(
        "save and fetch preserves countries for all continents",
        arguments: Continent.allCases
    )
    func save_andFetch_preservesCountriesPerContinent(continent: Continent) async throws {
        let sut = makeSUT()
        let countries = [Country.fixture(name: continent.rawValue)]

        try await sut.save(countries: countries, for: continent)
        let result = try await sut.fetchCountries(for: continent, ttl: 3600)

        #expect(result == countries)
    }
}

// MARK: - Test Infrastructure

private extension CountryCacheStoreTests {

    typealias SUT = CountryCacheStore

    func makeSUT() -> SUT {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let sut = CountryCacheStore(baseURL: tempURL)
        trackForMemoryLeaks([sut])
        return sut
    }
}
