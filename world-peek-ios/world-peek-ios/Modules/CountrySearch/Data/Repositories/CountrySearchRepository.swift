import Foundation

final class CountrySearchRepository: CountrySearchRepositoring {
    private let service: CountrySearchServicing
    private let cacheStore: CountryCacheStoring
    private let cacheConfiguration: CacheConfiguration

    init(
        service: CountrySearchServicing,
        cacheStore: CountryCacheStoring,
        cacheConfiguration: CacheConfiguration
    ) {
        self.service = service
        self.cacheStore = cacheStore
        self.cacheConfiguration = cacheConfiguration
    }

    func fetchCountries(for continent: Continent) async throws -> [Country] {
        let cached = try? await cacheStore.fetchCountries(for: continent, ttl: cacheConfiguration.countryCacheTTL)
        if let cached, !cached.isEmpty { return cached }

        let dtos = try await service.fetchCountries(region: continent.rawValue)
        let countries = dtos.compactMap { CountryDTOToCountryDomainMapper.map(dto: $0) }
        try? await cacheStore.save(countries: countries, for: continent)
        return countries
    }
}
