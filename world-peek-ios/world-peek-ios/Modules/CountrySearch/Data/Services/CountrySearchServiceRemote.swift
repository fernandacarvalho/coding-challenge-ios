import Foundation

final class CountrySearchServiceRemote: CountrySearchServicing {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchCountries(region: String) async throws -> [CountryDTO] {
        guard var components = URLComponents(string: Constants.baseURL) else {
            throw HTTPClientError.unknown
        }
        components.queryItems = [
            URLQueryItem(name: "region", value: region),
            URLQueryItem(name: "limit", value: "\(Constants.limit)"),
            URLQueryItem(name: "response_fields", value: Constants.responseFields)
        ]
        guard let url = components.url else {
            throw HTTPClientError.unknown
        }

        let (data, _) = try await client.send(URLRequest(url: url))
        let response = try JSONDecoder().decode(CountriesV5Response.self, from: data)
        return response.data.objects
    }
}

private extension CountrySearchServiceRemote {
    enum Constants {
        static let baseURL = "https://api.restcountries.com/countries/v5"
        static let limit = 100
        static let responseFields = [
            "names.common", "names.official",
            "flag.url_png", "flag.url_svg",
            "region", "subregion", "population",
            "capitals.name", "coordinates",
            "currencies", "languages.name",
            "links.google_maps"
        ].joined(separator: ",")
    }
}
