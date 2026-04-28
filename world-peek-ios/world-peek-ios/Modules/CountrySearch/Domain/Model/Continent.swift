import Foundation

enum Continent: String, CaseIterable, Identifiable {
    case africa = "Africa"
    case asia = "Asia"
    case europe = "Europe"
    case americas = "Americas"
    case oceania = "Oceania"

    var id: String { rawValue }
    var label: String { rawValue }

    var icon: String {
        switch self {
        case .africa:   return "africa"
        case .asia:     return "asia"
        case .europe:   return "europe"
        case .americas: return "america"
        case .oceania:  return "oceania"
        }
    }

    init?(regionName: String) {
        switch regionName {
        case "Africa":   self = .africa
        case "Asia":     self = .asia
        case "Europe":   self = .europe
        case "Americas": self = .americas
        case "Oceania":  self = .oceania
        default:         return nil
        }
    }
}
