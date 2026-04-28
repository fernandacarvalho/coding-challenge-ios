import Foundation

final class CountrySearchServiceRemote: CountrySearchServicing {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchCountries(region: String) async throws -> [CountryDTO] {
        guard let url = URL(string: "\(Constants.baseURL)/\(region.lowercased())?fields=\(Constants.fields)") else {
            throw HTTPClientError.unknown
        }
        let (data, _) = try await client.send(URLRequest(url: url))
        return try JSONDecoder().decode([CountryDTO].self, from: data)
    }
}

private extension CountrySearchServiceRemote {
    enum Constants {
        static let baseURL = "https://restcountries.com/v3.1/region"
        static let fields = "name,capital,maps,flags,region,subregion,population,currencies,tld,languages"
    }
}
