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
    static func make(
        deps: AppDependencies,
        country: Country
    ) -> (UIViewController, CountryDetailsViewModel) {
        let viewModel = CountryDetailsViewModel(country: country)
        let rootView = CountryDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)

        return (hostingController, viewModel)
    }
}
