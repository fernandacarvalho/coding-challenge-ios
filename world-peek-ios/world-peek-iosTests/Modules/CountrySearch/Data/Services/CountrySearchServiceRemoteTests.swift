import Testing
import Foundation
@testable import world_peek_ios

@Suite("CountrySearchServiceRemote")
final class CountrySearchServiceRemoteTests: Test.WorldPeekTesting {

    @Test(
        "fetchCountries builds correct URL with region, limit and response_fields",
        arguments: Continent.allCases
    )
    func fetchCountries_buildsCorrectURL(region: Continent) async throws {
        let (sut, spies) = makeSUT()
        spies.httpClient.sendToBeReturned = .success(makeValidResponse())

        _ = try await sut.fetchCountries(region: region.rawValue)

        let url = try #require(spies.httpClient.sendReceivedRequests[0].url)
        #expect(url.absoluteString.contains("https://api.restcountries.com/countries/v5") == true)

        let queryItems = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        #expect(queryItems.contains(URLQueryItem(name: "region", value: region.rawValue)))
        #expect(queryItems.contains(URLQueryItem(name: "limit", value: "100")))
        #expect(queryItems.contains { $0.name == "response_fields" && $0.value?.contains("names.common") == true })
    }

    @Test("fetchCountries decodes valid JSON response into CountryDTO array")
    func fetchCountries_decodesValidResponse() async throws {
        let (sut, spies) = makeSUT()
        spies.httpClient.sendToBeReturned = .success(makeValidResponse())

        let result = try await sut.fetchCountries(region: Continent.americas.rawValue)

        #expect(result.count == 1)
        await #expect(result[0].names.common == "Brazil")
    }

    @Test("fetchCountries propagates HTTPClient error")
    func fetchCountries_propagatesClientError() async {
        let (sut, spies) = makeSUT()
        spies.httpClient.sendToBeReturned = .failure(HTTPClientError.noInternetConnection)

        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchCountries(region: Continent.asia.rawValue)
        }
    }

    @Test("fetchCountries throws on invalid JSON")
    func fetchCountries_throwsOnInvalidJSON() async {
        let (sut, spies) = makeSUT()
        let invalidResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        spies.httpClient.sendToBeReturned = .success((Data("not-json".utf8), invalidResponse))

        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchCountries(region: Continent.africa.rawValue)
        }
    }
}

// MARK: - Test Infrastructure

private extension CountrySearchServiceRemoteTests {

    typealias SUT = CountrySearchServiceRemote

    struct Spies {
        let httpClient: HTTPClientSpy
    }

    func makeSUT() -> (SUT, Spies) {
        let httpClient = HTTPClientSpy()
        let sut = CountrySearchServiceRemote(client: httpClient)

        trackForMemoryLeaks([httpClient, sut])

        return (sut, Spies(httpClient: httpClient))
    }

    func makeValidResponse() -> (Data, HTTPURLResponse) {
        let json = """
        {
            "data": {
                "objects": [{
                    "names": { "common": "Brazil", "official": "Federative Republic of Brazil" },
                    "flag": {
                        "url_png": "https://flagcdn.com/w320/br.png",
                        "url_svg": "https://flagcdn.com/br.svg"
                    },
                    "region": "Americas",
                    "subregion": "South America",
                    "population": 214326000,
                    "capitals": [{ "name": "Brasília" }],
                    "coordinates": { "lat": -10.0, "lng": -55.0 },
                    "currencies": [{ "code": "BRL", "name": "Brazilian real", "symbol": "R$" }],
                    "languages": [{ "name": "Portuguese" }],
                    "links": { "google_maps": "https://goo.gl/maps/brazil" }
                }],
                "meta": { "total": 1, "count": 1, "limit": 100, "offset": 0, "more": false }
            }
        }
        """
        let response = HTTPURLResponse(
            url: URL(string: "https://api.restcountries.com/countries/v5")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (Data(json.utf8), response)
    }
}
