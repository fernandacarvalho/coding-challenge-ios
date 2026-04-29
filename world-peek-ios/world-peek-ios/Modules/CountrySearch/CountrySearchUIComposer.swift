import SwiftUI
import UIKit

enum CountrySearchUIComposer {
    static func make(
        deps: AppDependencies,
    ) -> (UIViewController, CountrySearchViewModel) {
        let service = CountrySearchServiceRemote(client: deps.httpClient)
        let repository = CountrySearchRepository(service: service)
        let viewModel = CountrySearchViewModel(repository: repository)
        viewModel.setup()
        let rootView = CountrySearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)

        return (hostingController, viewModel)
    }
}
