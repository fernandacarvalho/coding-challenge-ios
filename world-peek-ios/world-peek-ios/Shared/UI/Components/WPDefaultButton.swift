//
//  WPDefaultButton.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 29/04/26.
//

import SwiftUI

struct WPDefaultButton: View {
    let icon: Image? = nil
    let title: String
    let accessibilityId: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 8) {
                if let icon {
                    icon
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(AppColor.textLight)
                        .tint(AppColor.primary)
                }
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(AppColor.textLight)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: Constants.buttonHeight)
        .frame(maxWidth: .infinity)
        .background(AppColor.primary)
        .cornerRadius(Constants.buttonRadius)
        .padding(.horizontal, Constants.buttonHorizontalPadding)
        .accessibilityIdentifier(accessibilityId)
    }
}

private extension WPDefaultButton {
    enum Constants {
        static let buttonHeight: CGFloat = 44
        static let buttonRadius: CGFloat = 22
        static let buttonHorizontalPadding: CGFloat = 16
    }
}
