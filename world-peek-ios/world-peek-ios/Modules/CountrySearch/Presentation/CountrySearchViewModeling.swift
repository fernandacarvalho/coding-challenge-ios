//
//  CountrySearchViewModeling.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation

protocol CountrySearchViewModeling {
    var countries: [Country] { get }
    var isLoading: Bool { get }
    var selectedContinent: Continent { get }
    var onSelectCountry: ((Country) -> Void)? { get set }

    func setup()
    func updateQuery(_ query: String)
    func selectContinent(_ continent: Continent)
    func selectCountry(_ country: Country)
}
