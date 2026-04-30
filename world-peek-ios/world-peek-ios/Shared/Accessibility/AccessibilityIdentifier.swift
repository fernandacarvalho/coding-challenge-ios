//
//  AccessibilityIdentifier.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 29/04/26.
//

import Foundation

enum AccessibilityIdentifier {
    enum CountrySearch {
        static let countrySearch = "country_search"
        static let continentFiltersSection = "continent_filters_section"
        static let countryList = "country_list"
        static let loadingIndicator = "loading_indicator"
        static let errorBanner = "error_banner"

        static func continentFilter(_ label: String) -> String {
            "continent_filter_\(label.lowercased().replacingOccurrences(of: " ", with: "_"))"
        }

        static func countryCard(_ id: String) -> String {
            "country_card_\(id)"
        }
    }

    enum CountryDetails {
        static let searchForTickets = "search_for_tickets"
        static let toggleCardButton = "toggle_card_button"
        static let infoCard = "info_card"

        static func infoRow(_ field: String) -> String {
            "info_row_\(field.lowercased())"
        }
    }
}
