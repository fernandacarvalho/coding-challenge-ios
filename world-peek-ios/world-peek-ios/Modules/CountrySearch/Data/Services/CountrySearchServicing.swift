//
//  CountrySearchServicing.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation

protocol CountrySearchServicing {
    func fetchCountries(region: String) async throws -> [CountryDTO]
}
