//
//  CountryDetailsCoordinator.swift
//  world-peek-ios
//
//  Created by Fernanda Carvalho on 28/04/26.
//

import Foundation
import UIKit

final class DetailsCoordinator: Coordinator {
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

        let (viewController, _) =
            CountryDetailsUIComposer.make(
                deps: deps,
                country: country
            )

        navigationController.pushViewController(
            viewController,
            animated: true
        )
    }

    deinit {
        onFinish?()
    }
}
