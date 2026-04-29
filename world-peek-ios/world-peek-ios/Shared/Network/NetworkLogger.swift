import Foundation

enum NetworkLogger {
    static func log(request: URLRequest) {
        #if DEBUG
        print("[→] \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "")")
       #endif
    }

    static func log(response: HTTPURLResponse, data: Data?) {
        #if DEBUG
        let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        print("[←] \(response.statusCode) \(response.url?.absoluteString ?? "") \(body)")
        #endif
    }

    static func log(error: Error) {
        #if DEBUG
        print("[✗] \(error.localizedDescription)")
        #endif
    }
}
