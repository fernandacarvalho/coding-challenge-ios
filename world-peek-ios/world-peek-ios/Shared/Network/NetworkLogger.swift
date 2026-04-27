import Foundation

enum NetworkLogger {
    static func log(request: URLRequest) {
        #if DEBUG
        print("[→] \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "")")
        #endif
    }

    static func log(response: HTTPURLResponse, data: Data?) {
        #if DEBUG
        print("[←] \(response.statusCode) \(response.url?.absoluteString ?? "")")
        #endif
    }

    static func log(error: Error) {
        #if DEBUG
        print("[✗] \(error.localizedDescription)")
        #endif
    }
}
