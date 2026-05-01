import Foundation

struct Country: Identifiable, Equatable, Sendable, Codable {
    let id: String
    let name: String
    let officialName: String
    let flagURL: URL
    let flagSVGURL: URL?
    let region: String
    let subregion: String?
    let currencies: [Currency]
    let population: Int
    let capital: [String]
    let mapsURL: URL?
    let latLong: LatLong?
    let languages: [String]
}

struct Currency: Equatable, Sendable, Codable {
    let name: String
    let symbol: String
}

struct LatLong: Equatable, Sendable, Codable {
    let lat: Double
    let long: Double
}
