import SwiftUI

struct CountryListView: View {
    let countries: [Country]
    let onSelect: (Country) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var containerSize: CGSize = .zero

    private var columns: [GridItem] {
        AdaptiveGridLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass,
            containerSize: containerSize
        ).gridItems()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Countries")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(AppColor.textSecondary)
                .padding(.horizontal, 20)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(countries) { country in
                        CountryCardView(country: country, onSelect: onSelect)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear { containerSize = geo.size }
                    .onChange(of: geo.size) { containerSize = $0 }
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifier.CountrySearch.countryList)
    }
}
