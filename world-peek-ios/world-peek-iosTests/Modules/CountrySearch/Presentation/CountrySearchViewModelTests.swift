import Testing
@testable import world_peek_ios

@Suite("CountrySearchViewModel")
@MainActor
final class CountrySearchViewModelTests: Test.MoisesTesting {

    @Test("on init, fetches countries for the first continent")
    func init_fetchesCountriesForInitialContinent() async {
        let (sut, spies) = makeSUT()
        sut.setup()
        await Task.yield()

        #expect(spies.repository.fetchCountriesCallsCount == 1)
        #expect(spies.repository.fetchCountriesReceivedContinents == [Continent.allCases[0]])
    }

    @Test("selectContinent calls repository with the new continent")
    func selectContinent_callsRepositoryWithNewContinent() async {
        let (sut, spies) = makeSUT()
        sut.setup()
        await Task.yield()

        sut.selectContinent(.europe)
        await Task.yield()

        #expect(spies.repository.fetchCountriesReceivedContinents.last == .europe)
    }

    @Test("when fetch succeeds, countries is updated")
    func fetch_onSuccess_updatesCountries() async {
        let expected = [Country.fixture()]
        let (sut, _) = makeSUT(toBeReturned: .success(expected))
        #expect(sut.countries.isEmpty)

        sut.setup()
        await Task.yield()

        #expect(sut.countries == expected)
    }

    @Test("when fetch fails, errorMessage is set and countries is empty")
    func fetch_onFailure_setsErrorMessage() async {
        let (sut, _) = makeSUT(toBeReturned: .failure(HTTPClientError.unknown))
        #expect(sut.errorMessage == nil)

        sut.setup()
        await Task.yield()

        #expect(sut.errorMessage != nil)
        #expect(sut.countries.isEmpty)
    }

    @Test("updateQuery updates searchQuery")
    func updateQuery_updatesSearchQuery() {
        let (sut, _) = makeSUT()

        sut.updateQuery("brazil")

        #expect(sut.searchQuery == "brazil")
    }

    @Test("filteredCountries with empty query returns all loaded countries")
    func filteredCountries_withEmptyQuery_returnsAll() async {
        let countries = [Country.fixture(id: "BR", name: "Brazil"), Country.fixture(id: "FR", name: "France")]
        let (sut, _) = makeSUT(toBeReturned: .success(countries))
        sut.setup()
        await Task.yield()

        #expect(sut.filteredCountries.count == 2)
    }

    @Test("filteredCountries with query filters countries by name")
    func filteredCountries_withQuery_filtersByName() async {
        let countries = [Country.fixture(id: "BR", name: "Brazil"), Country.fixture(id: "FR", name: "France")]
        let (sut, _) = makeSUT(toBeReturned: .success(countries))
        sut.setup()
        await Task.yield()
        #expect(sut.filteredCountries.count == 2)

        sut.updateQuery("braz")

        #expect(sut.filteredCountries.count == 1)
        #expect(sut.filteredCountries[0].name == "Brazil")
    }
}

// MARK: - Test Infrastructure

private extension CountrySearchViewModelTests {

    typealias SUT = CountrySearchViewModel

    struct Spies {
        let repository: CountrySearchRepositorySpy
    }

    func makeSUT(
        toBeReturned: Result<[Country], Error> = .success([])
    ) -> (SUT, Spies) {
        let repository = CountrySearchRepositorySpy()
        repository.fetchCountriesToBeReturned = toBeReturned

        let sut = CountrySearchViewModel(repository: repository)

        trackForMemoryLeaks([repository, sut])

        return (sut, Spies(repository: repository))
    }
}
