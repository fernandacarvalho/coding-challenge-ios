import Foundation

struct ContinentCache: Codable {
    let cachedAt: Date
    let countries: [Country]
}
