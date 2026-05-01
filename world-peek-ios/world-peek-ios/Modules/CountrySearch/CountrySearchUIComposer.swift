import SwiftUI
import UIKit

enum CountrySearchUIComposer {
    static func make(
        deps: AppDependencies,
    ) -> (UIViewController, CountrySearchViewModel) {
        let service = CountrySearchServiceRemote(client: deps.httpClient)
        let cacheStore = CountryCacheStore()
        let repository = CountrySearchRepository(
            service: service,
            cacheStore: cacheStore,
            cacheConfiguration: deps.cacheConfiguration
        )
        let viewModel = CountrySearchViewModel(repository: repository)
        viewModel.setup()
        let rootView = CountrySearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.navigationItem.backButtonDisplayMode = .minimal

        return (hostingController, viewModel)
    }
}
