import Foundation

final class CountryCacheStore: CountryCacheStoring {
    private let baseURL: URL
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    init(baseURL: URL = CountryCacheStore.defaultBaseURL()) {
        self.baseURL = baseURL
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    func fetchCountries(for continent: Continent, ttl: TimeInterval) async throws -> [Country] {
        let url = fileURL(for: continent)
        guard
            let data = try? Data(contentsOf: url),
            let cache = try? decoder.decode(ContinentCache.self, from: data),
            Date().timeIntervalSince(cache.cachedAt) < ttl
        else {
            return []
        }
        return cache.countries
    }

    func save(countries: [Country], for continent: Continent) async throws {
        let cache = ContinentCache(cachedAt: Date(), countries: countries)
        let data = try encoder.encode(cache)
        try data.write(to: fileURL(for: continent), options: .atomic)
    }
}

private extension CountryCacheStore {
    func fileURL(for continent: Continent) -> URL {
        baseURL.appendingPathComponent("\(continent.rawValue.lowercased()).json")
    }

    static func defaultBaseURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("countries")
    }
}
