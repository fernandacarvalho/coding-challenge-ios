//
//  CountryDetailsCoordinator.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation
import UIKit

final class CountryDetailsCoordinator: Coordinator {
    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?

    private let deps: AppDependencies
    private let country: Country

    init(
        navigationController: UINavigationController,
        deps: AppDependencies,
        country: Country
    ) {
        self.navigationController = navigationController
        self.deps = deps
        self.country = country
    }

    func start() {
        let (viewController, viewModel) = CountryDetailsUIComposer.make(deps: deps, country: country)
        bindViewModel(to: viewModel)

        navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    deinit {
        onFinish?()
    }
}

private extension CountryDetailsCoordinator {
    func bindViewModel(to viewModel: CountryDetailsViewModel) {
        viewModel.onOpenURL = { url in
            UIApplication.shared.open(url)
        }
    }
}
