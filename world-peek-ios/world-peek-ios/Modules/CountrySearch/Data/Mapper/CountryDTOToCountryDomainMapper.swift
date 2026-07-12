//
//  CountryDTOToCountryDomainMapper.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation

struct CountryDTOToCountryDomainMapper {
    static func map(dto: CountryDTO) -> Country? {
        guard let flagURL = dto.flag.urlPng.flatMap({ URL(string: $0) }) else { return nil }

        let mappedCurrencies = dto.currencies?.map { Currency(name: $0.name ?? "", symbol: $0.symbol ?? "") } ?? []

        return Country(
            id: dto.names.common,
            name: dto.names.common,
            officialName: dto.names.official,
            flagURL: flagURL,
            flagSVGURL: dto.flag.urlSvg.flatMap { URL(string: $0) },
            region: dto.region,
            subregion: dto.subregion,
            currencies: mappedCurrencies,
            population: dto.population,
            capital: dto.capitals?.map { $0.name } ?? [],
            mapsURL: dto.links?.googleMaps.flatMap { URL(string: $0) },
            latLong: dto.coordinates.map { LatLong(lat: $0.lat, long: $0.lng) },
            languages: dto.languages?.map { $0.name } ?? []
        )
    }
}
