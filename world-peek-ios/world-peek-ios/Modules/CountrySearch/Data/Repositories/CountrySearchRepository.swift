import Foundation

final class CountrySearchRepository: CountrySearchRepositoring {
    private let service: CountrySearchServicing
    private var cache: [Continent: [Country]] = [:]

    init(service: CountrySearchServicing) {
        self.service = service
    }

    func fetchCountries(for continent: Continent) async throws -> [Country] {
        if let cached = cache[continent] { return cached }
        let dtos = try await service.fetchCountries(region: continent.rawValue)
        let countries = dtos.compactMap { CountryDTOToCountryDomainMapper.map(dto: $0) }
        cache[continent] = countries
        return countries
    }
}
