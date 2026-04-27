import Foundation

enum Continent: String, CaseIterable, Identifiable {
    case africa = "Africa"
    case asia = "Asia"
    case europe = "Europe"
    case americas = "Americas"
    case oceania = "Oceania"

    var id: String { rawValue }
    var label: String { rawValue }

    var systemImage: String {
        switch self {
        case .africa:   return "sun.max.fill"
        case .asia:     return "building.2.fill"
        case .europe:   return "building.columns.fill"
        case .americas: return "globe.americas.fill"
        case .oceania:  return "drop.fill"
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
