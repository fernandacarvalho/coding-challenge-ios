import Foundation

struct AppDependencies {
    let httpClient: HTTPClient
}

extension AppDependencies {
    static func live() -> AppDependencies {
        AppDependencies(
            httpClient: URLSessionHTTPClient(session: .shared)
        )
    }
}
