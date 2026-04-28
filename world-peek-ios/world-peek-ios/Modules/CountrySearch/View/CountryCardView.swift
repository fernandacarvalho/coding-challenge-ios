import SwiftUI

struct CountryCardView: View {
    let country: Country

    var body: some View {
        VStack(spacing: 0) {
            flagImage

            Text(country.name)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .leading)
                .background(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

private extension CountryCardView {
    var flagImage: some View {
        Color.teaGreen
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .overlay {
                AsyncImage(url: country.flagURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundColor(.mutedTeal)
                    } else {
                        ProgressView().tint(.mutedTeal)
                    }
                }
            }
            .clipped()
    }
}
