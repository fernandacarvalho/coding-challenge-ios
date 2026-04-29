import Testing
import Foundation
@testable import world_peek_ios

@Suite("CountryDTOToCountryDomainMapper")
final class CountryDTOToCountryDomainMapperTests: Test.MoisesTesting {

    @Test("maps all fields from DTO to domain entity")
    func map_withFullDTO_mapsAllFieldsCorrectly() {
        let dto = CountryDTO.fixture(
            name: .init(common: "Germany", official: "Federal Republic of Germany"),
            flags: .init(png: "https://flagcdn.com/w320/de.png", svg: "https://flagcdn.com/de.svg"),
            currencies: ["EUR": .init(name: "Euro", symbol: "€")],
            region: "Europe",
            subregion: "Western Europe",
            population: 83_000_000,
            capital: ["Berlin"],
            maps: .init(googleMaps: "https://goo.gl/maps/germany"),
            latlng: [-30.0, -71.0],
            languages: ["deu": "German"]
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.id == "Germany")
        #expect(country?.name == "Germany")
        #expect(country?.officialName == "Federal Republic of Germany")
        #expect(country?.flagURL == URL(string: "https://flagcdn.com/w320/de.png"))
        #expect(country?.flagSVGURL == URL(string: "https://flagcdn.com/de.svg"))
        #expect(country?.region == "Europe")
        #expect(country?.subregion == "Western Europe")
        #expect(country?.currencies == [Currency(name: "Euro", symbol: "€")])
        #expect(country?.population == 83_000_000)
        #expect(country?.capital == ["Berlin"])
        #expect(country?.mapsURL == URL(string: "https://goo.gl/maps/germany"))
        #expect(country?.latLong == LatLong(lat: -30.0, long: -71.0))
        #expect(country?.languages == ["German"])
    }

    @Test("uses name.common as both id and name")
    func map_usesCommonNameAsIdAndName() {
        let dto = CountryDTO.fixture(
            name: .init(common: "Brazil", official: "Federative Republic of Brazil")
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.id == "Brazil")
        #expect(country?.name == "Brazil")
        #expect(country?.officialName == "Federative Republic of Brazil")
    }

    @Test("returns nil when flag PNG URL string is invalid")
    func map_withInvalidFlagPNGURL_returnsNil() {
        let dto = CountryDTO.fixture(
            flags: .init(png: "", svg: "https://flagcdn.com/br.svg")
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country == nil)
    }

    @Test("maps invalid flag SVG URL string to nil flagSVGURL")
    func map_withInvalidFlagSVGURL_mapsFlagSVGURLToNil() {
        let dto = CountryDTO.fixture(
            flags: .init(png: "https://flagcdn.com/w320/br.png", svg: "")
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country != nil)
        #expect(country?.flagSVGURL == nil)
    }

    @Test("maps nil currencies to empty array")
    func map_withNilCurrencies_mapsToEmptyCurrenciesArray() {
        let dto = CountryDTO.fixture(currencies: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.currencies == [])
    }

    @Test("maps multiple currencies preserving all entries")
    func map_withMultipleCurrencies_mapsAllCurrencies() {
        let dto = CountryDTO.fixture(
            currencies: [
                "BRL": .init(name: "Brazilian real", symbol: "R$"),
                "USD": .init(name: "United States dollar", symbol: "$")
            ]
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.currencies.count == 2)
    }

    @Test("maps nil subregion to nil")
    func map_withNilSubregion_mapsToNilSubregion() {
        let dto = CountryDTO.fixture(subregion: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.subregion == nil)
    }

    @Test("maps nil capital to empty array")
    func map_withNilCapital_mapsToEmptyCapitalArray() {
        let dto = CountryDTO.fixture(capital: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.capital == [])
    }

    @Test("maps nil maps to nil mapsURL")
    func map_withNilMaps_mapsMapsURLToNil() {
        let dto = CountryDTO.fixture(maps: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.mapsURL == nil)
    }

    @Test("maps invalid googleMaps URL string to nil mapsURL")
    func map_withInvalidGoogleMapsURL_mapsMapsURLToNil() {
        let dto = CountryDTO.fixture(maps: .init(googleMaps: ""))

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.mapsURL == nil)
    }

    @Test("maps nil tld to empty array")
    func map_withNilLatlng_mapsToNilLatLong() {
        let dto = CountryDTO.fixture(latlng: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.latLong == nil)
    }

    @Test("maps nil languages to empty array")
    func map_withNilLanguages_mapsToEmptyLanguagesArray() {
        let dto = CountryDTO.fixture(languages: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.languages == [])
    }

    @Test("maps multiple languages preserving all values")
    func map_withMultipleLanguages_mapsAllLanguageValues() {
        let dto = CountryDTO.fixture(
            languages: ["por": "Portuguese", "eng": "English"]
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.languages.count == 2)
        #expect(country?.languages.contains("Portuguese") == true)
        #expect(country?.languages.contains("English") == true)
    }
}
