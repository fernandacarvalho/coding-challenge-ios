import Foundation
import Combine

@MainActor
final class CountrySearchViewModel: ObservableObject {
    @Published private(set) var searchQuery: String = ""
    @Published private(set) var selectedContinent: Continent = Continent.allCases[0]
    @Published private(set) var countries: [Country] = Country.samples

    var filteredCountries: [Country] {
        countries.filter { country in
            country.region == selectedContinent.rawValue &&
            (searchQuery.isEmpty || country.name.localizedCaseInsensitiveContains(searchQuery))
        }
    }

    func updateQuery(_ query: String) {
        searchQuery = query
    }

    func selectContinent(_ continent: Continent) {
        selectedContinent = continent
    }

    init() {}
}
