import Foundation
@testable import world_peek_ios

extension Country {
    static func fixture(
        id: String = "BR",
        name: String = "Brazil",
        officialName: String = "Federative Republic of Brazil",
        flagURL: URL = URL(string: "https://flagcdn.com/w320/br.png")!,
        flagSVGURL: URL? = nil,
        region: String = "Americas",
        subregion: String? = "South America",
        currencies: [Currency] = [Currency(name: "Brazilian real", symbol: "R$")],
        population: Int = 214_326_000,
        capital: [String] = ["Brasília"],
        mapsURL: URL? = nil,
        latLong: LatLong? = nil,
        languages: [String] = ["Portuguese"]
    ) -> Country {
        Country(
            id: id,
            name: name,
            officialName: officialName,
            flagURL: flagURL,
            flagSVGURL: flagSVGURL,
            region: region,
            subregion: subregion,
            currencies: currencies,
            population: population,
            capital: capital,
            mapsURL: mapsURL,
            latLong: latLong,
            languages: languages
        )
    }
}
