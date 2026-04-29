//
//  CountrySearchCoordinator.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation
import UIKit

final class SearchCoordinator: Coordinator {
    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []
    var onCountrySelected: ((Country) -> Void)?

    private let deps: AppDependencies

    init(
        navigationController: UINavigationController,
        deps: AppDependencies
    ) {
        self.navigationController = navigationController
        self.deps = deps
    }

    func start() {
        let (viewController, viewModel) =
            CountrySearchUIComposer.make(
                deps: deps
            )

        viewModel.onSelectCountry = { [weak self] country in
            self?.onCountrySelected?(country)
        }

        navigationController.setViewControllers(
            [viewController],
            animated: false
        )
    }
}
