import SwiftUI

struct FlightSearchView: View {
    @StateObject var viewModel: FlightSearchViewModel

    var body: some View {
        WebView(url: viewModel.url)
    }
}
