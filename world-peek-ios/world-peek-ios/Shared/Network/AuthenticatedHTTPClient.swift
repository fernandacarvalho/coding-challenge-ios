import Foundation

final class AuthenticatedHTTPClient: HTTPClient {
    private let wrapped: HTTPClient
    private let apiKey: String

    init(wrapping wrapped: HTTPClient, apiKey: String) {
        self.wrapped = wrapped
        self.apiKey = apiKey
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var authenticatedRequest = request
        authenticatedRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return try await wrapped.send(authenticatedRequest)
    }
}
