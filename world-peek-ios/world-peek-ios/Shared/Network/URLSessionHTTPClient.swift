import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        NetworkLogger.log(request: request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            NetworkLogger.log(error: error)
            throw mapURLError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.unknown
        }

        NetworkLogger.log(response: httpResponse, data: data)

        switch httpResponse.statusCode {
        case 200..<300:
            return (data, httpResponse)
        default:
            throw HTTPClientError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func mapURLError(_ error: Error) -> HTTPClientError {
        guard let urlError = error as? URLError else { return .unknown }
        switch urlError.code {
        case .notConnectedToInternet: return .noInternetConnection
        case .timedOut:               return .requestTimeout
        default:                      return .unknown
        }
    }
}
