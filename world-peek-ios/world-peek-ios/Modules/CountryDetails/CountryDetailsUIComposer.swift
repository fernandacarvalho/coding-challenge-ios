//
//  CountryDetailsUIComposer.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation
import SwiftUI
import UIKit

enum CountryDetailsUIComposer {
    @MainActor static func make(
        deps: AppDependencies,
        country: Country
    ) -> (UIViewController, CountryDetailsViewModel) {
        let viewModel = CountryDetailsViewModel(country: country)
        let rootView = CountryDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)

        let transparentAppearance = UINavigationBarAppearance()
        transparentAppearance.configureWithTransparentBackground()
        hostingController.navigationItem.standardAppearance = transparentAppearance
        hostingController.navigationItem.scrollEdgeAppearance = transparentAppearance
        hostingController.navigationItem.compactAppearance = transparentAppearance

        return (hostingController, viewModel)
    }
}
