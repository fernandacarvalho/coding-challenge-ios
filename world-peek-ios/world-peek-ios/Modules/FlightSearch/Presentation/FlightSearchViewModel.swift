import Combine
import Foundation

@MainActor
final class FlightSearchViewModel: ObservableObject {
    @Published private(set) var url: URL

    init(url: URL) {
        self.url = url
    }
}
