//
//  CountryDetailsViewModel.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Combine
import Foundation

final class CountryDetailsViewModel: CountryDetailsViewModeling, ObservableObject {
    // MARK: Outputs
    private(set) var country: Country

    @Published var isCardExpanded = true

    var onOpenURL: ((URL) -> Void)?

    init(country: Country) {
        self.country = country
    }

    // MARK: Inputs

    func toggleCard() {
        isCardExpanded.toggle()
    }

    func searchForTickets() {
        let destination = country.capital.first ?? country.name
        let query = "Flights to \(destination)"

        guard
            let encoded = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ),
            let url = URL(
                string: "https://www.google.com/travel/flights?q=\(encoded)"
            )
        else {
            return
        }
        onOpenURL?(url)
    }
}
