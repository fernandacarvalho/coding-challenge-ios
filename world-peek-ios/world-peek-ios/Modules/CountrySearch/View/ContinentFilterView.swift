import SwiftUI

struct ContinentFilterView: View {
    let continent: Continent
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColor.primary : .white)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

                    Image(continent.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(
                            isSelected ? .white : AppColor.secondary
                        )
                }
            }
            .buttonStyle(.plain)

            Text(continent.label)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 64)
        }
    }
}
