//
//  CountryDetailsViewModel.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Combine
import Foundation

final class CountryDetailsViewModel: ObservableObject {
    private(set) var country: Country
    
    init(country: Country) {
        self.country = country
    }
}
