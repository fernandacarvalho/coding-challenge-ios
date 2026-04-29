import SwiftUI

struct CountryListView: View {
    let countries: [Country]
    let onSelect: (Country) -> Void

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible())
    ]

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
    }
}
