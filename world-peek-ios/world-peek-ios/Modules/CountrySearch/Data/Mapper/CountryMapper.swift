import Foundation

struct CountryMapper: Decodable {
    struct Name: Decodable {
        let common: String
        let official: String
    }

    struct Flags: Decodable {
        let png: String
        let svg: String
    }

    struct CurrencyInfo: Decodable {
        let name: String
        let symbol: String
    }

    struct Maps: Decodable {
        let googleMaps: String
    }

    let name: Name
    let flags: Flags
    let currencies: [String: CurrencyInfo]?
    let region: String
    let subregion: String?
    let population: Int
    let capital: [String]?
    let maps: Maps?
    let tld: [String]?
    let languages: [String: String]?

    func toDomain() -> Country? {
        guard let flagURL = URL(string: flags.png) else { return nil }

        let mappedCurrencies = currencies?.values.map { Currency(name: $0.name, symbol: $0.symbol) } ?? []

        return Country(
            id: name.common,
            name: name.common,
            officialName: name.official,
            flagURL: flagURL,
            flagSVGURL: URL(string: flags.svg),
            region: region,
            subregion: subregion,
            currencies: mappedCurrencies,
            population: population,
            capital: capital ?? [],
            mapsURL: maps.flatMap { URL(string: $0.googleMaps) },
            tld: tld ?? [],
            languages: languages.map { Array($0.values) } ?? []
        )
    }
}
