//
//  CountryDTOToCountryDomainMapper.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation

struct CountryDTOToCountryDomainMapper {
    static func map(dto: CountryDTO) -> Country? {
        guard let flagURL = URL(string: dto.flags.png) else { return nil }

        let mappedCurrencies = dto.currencies?.values.map { Currency(name: $0.name, symbol: $0.symbol) } ?? []

        return Country(
            id: dto.name.common,
            name: dto.name.common,
            officialName: dto.name.official,
            flagURL: flagURL,
            flagSVGURL: URL(string: dto.flags.svg),
            region: dto.region,
            subregion: dto.subregion,
            currencies: mappedCurrencies,
            population: dto.population,
            capital: dto.capital ?? [],
            mapsURL: dto.maps.flatMap { URL(string: $0.googleMaps) },
            tld: dto.tld ?? [],
            languages: dto.languages.map { Array($0.values) } ?? []
        )
    }
}
