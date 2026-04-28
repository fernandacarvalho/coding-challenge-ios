import Foundation
@testable import world_peek_ios

final class CountrySearchRepositorySpy: CountrySearchRepositoring {
    private(set) var fetchCountriesCallsCount = 0
    private(set) var fetchCountriesReceivedContinents: [Continent] = []
    var fetchCountriesToBeReturned: Result<[Country], Error> = .success([])

    func fetchCountries(for continent: Continent) async throws -> [Country] {
        fetchCountriesCallsCount += 1
        fetchCountriesReceivedContinents.append(continent)
        return try fetchCountriesToBeReturned.get()
    }
}
