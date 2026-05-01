import Foundation
@testable import world_peek_ios

final class CountryCacheStoringSpy: CountryCacheStoring {
    private(set) var fetchCallsCount = 0
    private(set) var fetchReceivedContinents: [Continent] = []
    var fetchToBeReturned: Result<[Country], Error> = .success([])

    private(set) var saveCallsCount = 0
    private(set) var saveReceivedContinents: [Continent] = []
    private(set) var saveReceivedCountries: [[Country]] = []

    func fetchCountries(for continent: Continent, ttl: TimeInterval) async throws -> [Country] {
        fetchCallsCount += 1
        fetchReceivedContinents.append(continent)
        return try fetchToBeReturned.get()
    }

    func save(countries: [Country], for continent: Continent) async throws {
        saveCallsCount += 1
        saveReceivedContinents.append(continent)
        saveReceivedCountries.append(countries)
    }
}
