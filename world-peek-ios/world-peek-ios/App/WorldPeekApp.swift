import SwiftUI

@main
struct WorldPeekApp: App {
    let dependencies = AppDependencies.live()
    private let coordinator: AppCoordinator

    init() {
        coordinator = AppCoordinator(deps: dependencies)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: coordinator)
                .ignoresSafeArea()
        }
    }
}
