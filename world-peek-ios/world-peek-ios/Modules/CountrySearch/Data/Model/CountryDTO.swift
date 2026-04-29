import Foundation

struct CountryDTO: Decodable {
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
    let latlng: [Double]?
    let languages: [String: String]?
}
