import SwiftUI
import UIKit

enum FlightSearchUIComposer {
    static func make(
        deps: AppDependencies,
        url: URL
    ) -> (UIViewController, FlightSearchViewModel) {
        let viewModel = FlightSearchViewModel(url: url)
        let rootView = FlightSearchView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)
        return (hostingController, viewModel)
    }
}
