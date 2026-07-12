import Foundation

enum AppSecrets {
    static var restCountriesAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "RestCountriesAPIKey") as? String ?? ""
    }
}
