import Foundation
@testable import world_peek_ios

final class HTTPClientSpy: HTTPClient {
    private(set) var sendCallsCount = 0
    private(set) var sendReceivedRequests: [URLRequest] = []
    var sendToBeReturned: Result<(Data, HTTPURLResponse), Error> = .success(
        (Data(), HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    )

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        sendCallsCount += 1
        sendReceivedRequests.append(request)
        return try sendToBeReturned.get()
    }
}
