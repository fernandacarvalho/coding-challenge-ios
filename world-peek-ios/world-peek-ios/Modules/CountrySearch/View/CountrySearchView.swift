import SwiftUI

struct CountrySearchView: View {
    @StateObject var viewModel: CountrySearchViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                header
                continentFilters
                contentArea
            }
            .padding(.top, 20)
            .background(AppColor.background01.ignoresSafeArea())
            .navigationBarHidden(true)

            VStack {
                Spacer()
                BottomFadeOverlay(startColor: AppColor.background01, endColor: .clear)
            }
            .ignoresSafeArea(.all)
        }
    }
}

private extension CountrySearchView {
    var header: some View {
        VStack {
            titleSection
            searchBar
        }
        .padding(.horizontal, 20)
    }

    var titleSection: some View {
        Text("World Peek")
            .font(.system(size: 28, weight: .bold, design: .default))
            .foregroundColor(AppColor.textPrimary)
    }

    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColor.secondary)
                .font(.system(size: 16, weight: .medium))
                .accessibilityHidden(true)

            TextField(
                "type a country",
                text: Binding(
                    get: { viewModel.searchQuery },
                    set: { viewModel.updateQuery($0) }
                )
            )
            .font(.system(size: 15))
            .foregroundColor(AppColor.textDark)
            .autocorrectionDisabled()
            .accessibilityIdentifier(AccessibilityIdentifier.CountrySearch.countrySearch)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    var continentFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Continent.allCases) { continent in
                    ContinentFilterView(
                        continent: continent,
                        isSelected: viewModel.selectedContinent == continent,
                        onTap: { viewModel.selectContinent(continent) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.CountrySearch.continentFiltersSection)
    }

    @ViewBuilder
    var contentArea: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier(AccessibilityIdentifier.CountrySearch.loadingIndicator)
        } else if let error = viewModel.errorMessage {
            ErrorBannerView(message: error)
                .padding(.bottom, 54)
        } else {
            CountryListView(countries: viewModel.filteredCountries, onSelect: viewModel.selectCountry(_:))
        }
    }
}
