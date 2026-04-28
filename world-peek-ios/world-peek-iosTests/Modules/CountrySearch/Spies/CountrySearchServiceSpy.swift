import Foundation
@testable import world_peek_ios

final class CountrySearchServiceSpy: CountrySearchServicing {
    private(set) var fetchCountriesCallsCount = 0
    private(set) var fetchCountriesReceivedRegions: [String] = []
    var fetchCountriesToBeReturned: Result<[CountryDTO], Error> = .success([])

    func fetchCountries(region: String) async throws -> [CountryDTO] {
        fetchCountriesCallsCount += 1
        fetchCountriesReceivedRegions.append(region)
        return try fetchCountriesToBeReturned.get()
    }
}
