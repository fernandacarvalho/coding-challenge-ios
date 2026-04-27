import Foundation

protocol HTTPClient {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

enum HTTPClientError: Error {
    case noInternetConnection
    case requestTimeout
    case serverError(statusCode: Int)
    case unknown
}
