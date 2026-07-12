import Foundation
@testable import world_peek_ios

extension CountryDTO {
    static func fixture(
        names: Names = Names(common: "Brazil", official: "Federative Republic of Brazil"),
        flag: Flag = Flag(urlPng: "https://flagcdn.com/w320/br.png", urlSvg: "https://flagcdn.com/br.svg"),
        currencies: [CurrencyInfo]? = [CurrencyInfo(name: "Brazilian real", symbol: "R$")],
        region: String = "Americas",
        subregion: String? = "South America",
        population: Int = 214_326_000,
        capitals: [Capital]? = [Capital(name: "Brasília")],
        links: Links? = nil,
        coordinates: Coordinates? = nil,
        languages: [Language]? = [Language(name: "Portuguese")]
    ) -> CountryDTO {
        CountryDTO(
            names: names,
            flag: flag,
            currencies: currencies,
            region: region,
            subregion: subregion,
            population: population,
            capitals: capitals,
            links: links,
            coordinates: coordinates,
            languages: languages
        )
    }
}
