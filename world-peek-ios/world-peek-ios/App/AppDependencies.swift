import Foundation

struct AppDependencies {
    let httpClient: HTTPClient
    let cacheConfiguration: CacheConfiguration
}

extension AppDependencies {
    static func live() -> AppDependencies {
        AppDependencies(
            httpClient: URLSessionHTTPClient(session: .shared),
            cacheConfiguration: .default
        )
    }
}
