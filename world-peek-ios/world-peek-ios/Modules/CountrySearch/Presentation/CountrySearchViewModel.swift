import Combine
import Foundation

final class CountrySearchViewModel: CountrySearchViewModeling, ObservableObject {
    // MARK: Dependencies
    private let repository: CountrySearchRepositoring

    // MARK: Properties
    private var fetchTask: Task<Void, Never>?

    // MARK: Outputs
    @Published private(set) var searchQuery: String = ""
    @Published private(set) var selectedContinent: Continent = Continent.allCases[0]
    @Published private(set) var countries: [Country] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    var filteredCountries: [Country] {
        guard !searchQuery.isEmpty else { return countries }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    var onSelectCountry: ((Country) -> Void)?

    init(repository: CountrySearchRepositoring) {
        self.repository = repository
    }

    // MARK: Inputs
    func setup() {
        loadCurrentContinent()
    }

    func updateQuery(_ query: String) {
        searchQuery = query
    }

    func selectContinent(_ continent: Continent) {
        selectedContinent = continent
        loadCurrentContinent()
    }

    func selectCountry(_ country: Country) {
        onSelectCountry?(country)
    }
}

private extension CountrySearchViewModel {
    func loadCurrentContinent() {
        fetchTask?.cancel()
        fetchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            isLoading = true
            errorMessage = nil
            do {
                let result = try await repository.fetchCountries(for: selectedContinent)
                guard !Task.isCancelled else { return }
                countries = result
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = String(localized: "Failed to load countries. Please try again.")
                countries = []
            }
            isLoading = false
        }
    }
}
