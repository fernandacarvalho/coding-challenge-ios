import UIKit
import SwiftUI

enum CountrySearchUIComposer {
    static func make(
        deps: AppDependencies
        // TODO: add external dependencies (navigation callbacks, IDs, preloaded data)
    ) -> (UIViewController, CountrySearchViewModel) {
        // 1) Build INTERNAL deps of the module here (Service → Repository → UseCase)
        //    using deps.* as the source for global dependencies.

        // 2) Build the ViewModel
        let viewModel = CountrySearchViewModel()

        // 3) Host the SwiftUI View
        let rootView = CountrySearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)

        // 4) Return the tuple
        return (hostingController, viewModel)
    }
}
