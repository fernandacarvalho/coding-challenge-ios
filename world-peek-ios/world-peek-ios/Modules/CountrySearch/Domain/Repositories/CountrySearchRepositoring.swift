import Foundation

protocol CountrySearchRepositoring {
    func fetchCountries(for continent: Continent) async throws -> [Country]
}
