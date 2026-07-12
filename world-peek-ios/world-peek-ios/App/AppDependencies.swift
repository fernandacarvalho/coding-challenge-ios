import Foundation

struct AppDependencies {
    let httpClient: HTTPClient
    let cacheConfiguration: CacheConfiguration
}

extension AppDependencies {
    static func live() -> AppDependencies {
        AppDependencies(
            httpClient: AuthenticatedHTTPClient(
                wrapping: URLSessionHTTPClient(session: .shared),
                apiKey: AppSecrets.restCountriesAPIKey
            ),
            cacheConfiguration: .default
        )
    }
}
