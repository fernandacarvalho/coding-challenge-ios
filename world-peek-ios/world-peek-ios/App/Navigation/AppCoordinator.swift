import UIKit

final class AppCoordinator: NSObject, Coordinator {
    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []

    private let deps: AppDependencies
    private let navigationGate = NavigationGate()

    init(deps: AppDependencies) {
        self.deps = deps
        self.navigationController = UINavigationController()

        super.init()

        navigationController.delegate = self
    }

    func start() {
        let searchCoordinator = CountrySearchCoordinator(
            navigationController: navigationController,
            deps: deps
        )

        searchCoordinator.onCountrySelected = { [weak self] country in
            self?.showDetails(country)
        }

        addChild(searchCoordinator)

        searchCoordinator.start()
    }
}

private extension AppCoordinator {
    func showDetails(_ country: Country) {
        Task { @MainActor [weak self] in
            guard
                let self,
                await navigationGate.tryEnter()
            else {
                return
            }

            let detailsCoordinator = CountryDetailsCoordinator(
                navigationController: navigationController,
                deps: deps,
                country: country
            )

            detailsCoordinator.onFinish = { [weak self] in
                guard let self else { return }
                self.removeChild(detailsCoordinator)
            }

            addChild(detailsCoordinator)

            detailsCoordinator.start()
        }
    }
}

extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        Task {
            await navigationGate.leave()
        }
    }
}
