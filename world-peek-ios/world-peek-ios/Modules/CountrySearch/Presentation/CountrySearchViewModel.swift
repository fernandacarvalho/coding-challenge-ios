import Foundation
import Combine

final class CountrySearchViewModel: ObservableObject {
    @Published private(set) var searchQuery: String = ""
    @Published private(set) var selectedContinent: Continent = Continent.allCases[0]
    @Published private(set) var countries: [Country] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let repository: CountrySearchRepositoring
    private var fetchTask: Task<Void, Never>?

    var filteredCountries: [Country] {
        guard !searchQuery.isEmpty else { return countries }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    init(repository: CountrySearchRepositoring) {
        self.repository = repository
    }
    
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
}

private extension CountrySearchViewModel {
    @MainActor
    func loadCurrentContinent() {
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            errorMessage = nil
            do {
                let result = try await repository.fetchCountries(for: selectedContinent)
                guard !Task.isCancelled else { return }
                countries = result
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = "Failed to load countries. Please try again."
                countries = []
            }
            isLoading = false
        }
    }
}
