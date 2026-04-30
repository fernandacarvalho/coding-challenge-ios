import SwiftUI

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColor.grayish)
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
