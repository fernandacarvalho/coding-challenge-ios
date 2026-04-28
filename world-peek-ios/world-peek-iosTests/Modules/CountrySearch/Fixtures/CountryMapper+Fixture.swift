import Foundation
@testable import world_peek_ios

extension CountryDTO {
    static func fixture(
        name: Name = Name(common: "Brazil", official: "Federative Republic of Brazil"),
        flags: Flags = Flags(png: "https://flagcdn.com/w320/br.png", svg: "https://flagcdn.com/br.svg"),
        currencies: [String: CurrencyInfo]? = ["BRL": CurrencyInfo(name: "Brazilian real", symbol: "R$")],
        region: String = "Americas",
        subregion: String? = "South America",
        population: Int = 214_326_000,
        capital: [String]? = ["Brasília"],
        maps: Maps? = nil,
        tld: [String]? = [".br"],
        languages: [String: String]? = ["por": "Portuguese"]
    ) -> CountryDTO {
        CountryDTO(
            name: name,
            flags: flags,
            currencies: currencies,
            region: region,
            subregion: subregion,
            population: population,
            capital: capital,
            maps: maps,
            tld: tld,
            languages: languages
        )
    }
}
