import Foundation

protocol CountryCacheStoring: AnyObject {
    func fetchCountries(for continent: Continent, ttl: TimeInterval) async throws -> [Country]
    func save(countries: [Country], for continent: Continent) async throws
}
