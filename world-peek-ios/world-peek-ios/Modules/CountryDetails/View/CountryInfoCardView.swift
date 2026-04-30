//
//  CountryInfoCardView.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Kingfisher
import SwiftUI

struct CountryInfoCardView: View {
    @ObservedObject var viewModel: CountryDetailsViewModel

    private let animation: Animation = .spring(
        response: 0.5,
        dampingFraction: 0.82
    )

    var body: some View {
        VStack(spacing: 0) {
            toggleButton
                .offset(y: 24)
            cardContent
        }
        .padding(.top, 24)
    }

    // MARK: Toggle

    private var toggleButton: some View {
        Button {
            withAnimation(animation) {
                viewModel.toggleCard()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(AppColor.background02)
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: -1)

                Image(systemName: "chevron.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColor.primary)
                    .rotationEffect(
                        .degrees(viewModel.isCardExpanded ? 180 : 0)
                    )
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(NoHighlightButtonStyle())
        .zIndex(2)
        .accessibilityIdentifier(AccessibilityIdentifier.CountryDetails.toggleCardButton)
        .accessibilityHint(AccessibilityHint.CountryDetails.toggleCardButton)
    }

    // MARK: Card

    private var cardContent: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 24)
            flagHeader
                .padding(.top, 8)

            Divider()
                .padding(.horizontal, 20)
                .opacity(viewModel.isCardExpanded ? 1 : 0)

            expandedContent
                .padding(.top, 16)
        }
        .padding(.bottom, viewModel.isCardExpanded ? 0 : 16)
        .background(AppColor.background02)
        .clipShape(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: -6)
    }

    // MARK: Flag Header

    private var flagHeader: some View {
        HStack(spacing: 14) {
            KFImage(viewModel.country.flagURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.country.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                    .lineLimit(2)

                Text(viewModel.country.officialName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppColor.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    // MARK: Expanded Content

    private var expandedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                iconRow(icon: "globe", key: "region", label: String(localized: "Region"), value: regionSubregionText)

                if !viewModel.country.capital.isEmpty {
                    iconRow(
                        icon: "building.columns.fill",
                        key: "capital",
                        label: String(localized: "Capital"),
                        value: viewModel.country.capital.joined(separator: ", ")
                    )
                }

                iconRow(
                    icon: "person.2.fill",
                    key: "population",
                    label: String(localized: "Population"),
                    value: formattedPopulation
                )

                if !viewModel.country.languages.isEmpty {
                    iconRow(
                        icon: "text.bubble.fill",
                        key: "languages",
                        label: String(localized: "Languages"),
                        value: viewModel.country.languages.joined(separator: ", ")
                    )
                }

                if !viewModel.country.currencies.isEmpty {
                    iconRow(
                        icon: "banknote.fill",
                        key: "currencies",
                        label: String(localized: "Currencies"),
                        value: formattedCurrencies
                    )
                }

                WPDefaultButton(
                    title: String(localized: "Search for tickets"),
                    accessibilityId: AccessibilityIdentifier.CountryDetails.searchForTickets,
                    action: viewModel.searchForTickets
                )
                .padding(.top, 24)
                .padding(.bottom, 16)
                .padding(.horizontal, 24)

                Color.clear.frame(height: safeAreaBottomPadding)
            }
        }
        .frame(maxHeight: viewModel.isCardExpanded ? 300 : 0, alignment: .top)
        .opacity(viewModel.isCardExpanded ? 1 : 0)
        .clipped()
        .accessibilityIdentifier(AccessibilityIdentifier.CountryDetails.infoCard)
    }

    // MARK: Row builder

    private func iconRow(icon: String, key: String, label: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppColor.success)
                .frame(width: 30, height: 30, alignment: .center)
                .accessibilityHidden(true)

            Text("\(label) : ")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColor.textPrimary)
                .fixedSize()

            Text(value)
                .font(.system(size: 13, weight: .regular))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(AppColor.textPrimary)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 30)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .accessibilityIdentifier(AccessibilityIdentifier.CountryDetails.infoRow(key))
    }
}

// MARK: Helpers

private extension CountryInfoCardView {
    var regionSubregionText: String {
        if let sub = viewModel.country.subregion, !sub.isEmpty {
            return "\(viewModel.country.region) · \(sub)"
        }
        return viewModel.country.region
    }

    var formattedPopulation: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        return formatter.string(
            from: NSNumber(value: viewModel.country.population)
        ) ?? "\(viewModel.country.population)"
    }

    var formattedCurrencies: String {
        viewModel.country.currencies
            .map { "\($0.name) (\($0.symbol))" }
            .joined(separator: ", ")
    }

    var safeAreaBottomPadding: CGFloat {
        (
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .windows
                .first?
                .safeAreaInsets.bottom
            ?? 0
        ) + 16
    }
}
