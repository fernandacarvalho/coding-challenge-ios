import Testing
import Foundation
@testable import world_peek_ios

@Suite("AuthenticatedHTTPClient")
final class AuthenticatedHTTPClientTests: Test.WorldPeekTesting {

    @Test("send sets Authorization Bearer header with the API key")
    func send_setsAuthorizationHeader() async throws {
        let (sut, spies) = makeSUT(apiKey: "test-api-key")

        _ = try await sut.send(URLRequest(url: try #require(URL(string: "https://example.com"))))

        let request = try #require(spies.wrapped.sendReceivedRequests.first)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-api-key")
    }

    @Test("send delegates to the wrapped client and returns its result")
    func send_delegatesToWrappedClient() async throws {
        let (sut, spies) = makeSUT()
        let expectedResponse = HTTPURLResponse(
            url: try #require(URL(string: "https://example.com")),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let expectedData = Data("payload".utf8)
        spies.wrapped.sendToBeReturned = .success((expectedData, try #require(expectedResponse)))

        let (data, response) = try await sut.send(URLRequest(url: try #require(URL(string: "https://example.com"))))

        #expect(spies.wrapped.sendCallsCount == 1)
        #expect(data == expectedData)
        #expect(response.statusCode == 200)
    }

    @Test("send propagates wrapped client error")
    func send_propagatesWrappedClientError() async {
        let (sut, spies) = makeSUT()
        spies.wrapped.sendToBeReturned = .failure(HTTPClientError.noInternetConnection)

        await #expect(throws: (any Error).self) {
            _ = try await sut.send(URLRequest(url: URL(string: "https://example.com")!))
        }
    }
}

// MARK: - Test Infrastructure

private extension AuthenticatedHTTPClientTests {

    typealias SUT = AuthenticatedHTTPClient

    struct Spies {
        let wrapped: HTTPClientSpy
    }

    func makeSUT(apiKey: String = "test-api-key") -> (SUT, Spies) {
        let wrapped = HTTPClientSpy()
        let sut = AuthenticatedHTTPClient(wrapping: wrapped, apiKey: apiKey)

        trackForMemoryLeaks([wrapped, sut])

        return (sut, Spies(wrapped: wrapped))
    }
}
