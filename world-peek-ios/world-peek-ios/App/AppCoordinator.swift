import UIKit

final class AppCoordinator {
    let navigationController: UINavigationController
    private let deps: AppDependencies

    init(deps: AppDependencies) {
        self.deps = deps
        self.navigationController = UINavigationController()
    }

    func start() {
        let (viewController, _) = CountrySearchUIComposer.make(deps: deps)
        navigationController.setViewControllers([viewController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}
