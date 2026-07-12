import Testing
import Foundation
@testable import world_peek_ios

@Suite("CountryDTOToCountryDomainMapper")
final class CountryDTOToCountryDomainMapperTests: Test.WorldPeekTesting {

    @Test("maps all fields from DTO to domain entity")
    func map_withFullDTO_mapsAllFieldsCorrectly() {
        let dto = CountryDTO.fixture(
            names: .init(common: "Germany", official: "Federal Republic of Germany"),
            flag: .init(urlPng: "https://flagcdn.com/w320/de.png", urlSvg: "https://flagcdn.com/de.svg"),
            currencies: [.init(name: "Euro", symbol: "€")],
            region: "Europe",
            subregion: "Western Europe",
            population: 83_000_000,
            capitals: [.init(name: "Berlin")],
            links: .init(googleMaps: "https://goo.gl/maps/germany"),
            coordinates: .init(lat: -30.0, lng: -71.0),
            languages: [.init(name: "German")]
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        let expectedLatLong = LatLong(lat: -30.0, long: -71.0)
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
        #expect(country?.latLong == expectedLatLong)
        #expect(country?.languages == ["German"])
    }

    @Test("uses names.common as both id and name")
    func map_usesCommonNameAsIdAndName() {
        let dto = CountryDTO.fixture(
            names: .init(common: "Brazil", official: "Federative Republic of Brazil")
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.id == "Brazil")
        #expect(country?.name == "Brazil")
        #expect(country?.officialName == "Federative Republic of Brazil")
    }

    @Test("returns nil when flag PNG URL string is invalid")
    func map_withInvalidFlagPNGURL_returnsNil() {
        let dto = CountryDTO.fixture(
            flag: .init(urlPng: "", urlSvg: "https://flagcdn.com/br.svg")
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country == nil)
    }

    @Test("returns nil when flag PNG URL is missing")
    func map_withNilFlagPNGURL_returnsNil() {
        let dto = CountryDTO.fixture(
            flag: .init(urlPng: nil, urlSvg: "https://flagcdn.com/br.svg")
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country == nil)
    }

    @Test("maps invalid flag SVG URL string to nil flagSVGURL")
    func map_withInvalidFlagSVGURL_mapsFlagSVGURLToNil() {
        let dto = CountryDTO.fixture(
            flag: .init(urlPng: "https://flagcdn.com/w320/br.png", urlSvg: "")
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
                .init(name: "Brazilian real", symbol: "R$"),
                .init(name: "United States dollar", symbol: "$")
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

    @Test("maps nil capitals to empty array")
    func map_withNilCapitals_mapsToEmptyCapitalArray() {
        let dto = CountryDTO.fixture(capitals: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.capital == [])
    }

    @Test("maps nil links to nil mapsURL")
    func map_withNilLinks_mapsMapsURLToNil() {
        let dto = CountryDTO.fixture(links: nil)

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.mapsURL == nil)
    }

    @Test("maps invalid googleMaps URL string to nil mapsURL")
    func map_withInvalidGoogleMapsURL_mapsMapsURLToNil() {
        let dto = CountryDTO.fixture(links: .init(googleMaps: ""))

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.mapsURL == nil)
    }

    @Test("maps nil coordinates to nil latLong")
    func map_withNilCoordinates_mapsToNilLatLong() {
        let dto = CountryDTO.fixture(coordinates: nil)

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
            languages: [.init(name: "Portuguese"), .init(name: "English")]
        )

        let country = CountryDTOToCountryDomainMapper.map(dto: dto)

        #expect(country?.languages.count == 2)
        #expect(country?.languages.contains("Portuguese") == true)
        #expect(country?.languages.contains("English") == true)
    }
}
