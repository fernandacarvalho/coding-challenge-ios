import Foundation

struct CountriesV5Response: Decodable {
    struct DataEnvelope: Decodable {
        let objects: [CountryDTO]
    }

    let data: DataEnvelope
}

struct CountryDTO: Decodable {
    struct Names: Decodable {
        let common: String
        let official: String
    }

    struct Flag: Decodable {
        let urlPng: String?
        let urlSvg: String?

        enum CodingKeys: String, CodingKey {
            case urlPng = "url_png"
            case urlSvg = "url_svg"
        }
    }

    struct CurrencyInfo: Decodable {
        let name: String?
        let symbol: String?
    }

    struct Language: Decodable {
        let name: String
    }

    struct Capital: Decodable {
        let name: String
    }

    struct Coordinates: Decodable {
        let lat: Double
        let lng: Double
    }

    struct Links: Decodable {
        let googleMaps: String?

        enum CodingKeys: String, CodingKey {
            case googleMaps = "google_maps"
        }
    }

    let names: Names
    let flag: Flag
    let currencies: [CurrencyInfo]?
    let region: String
    let subregion: String?
    let population: Int
    let capitals: [Capital]?
    let links: Links?
    let coordinates: Coordinates?
    let languages: [Language]?
}
