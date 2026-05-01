import Foundation
@testable import world_peek_ios

extension AppDependencies {
    static func makeForTesting() -> AppDependencies {
        AppDependencies(
            httpClient: HTTPClientSpy(),
            cacheConfiguration: .testing
        )
    }
}
