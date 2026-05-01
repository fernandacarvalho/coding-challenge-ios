import Foundation

struct CacheConfiguration {
    let countryCacheTTL: TimeInterval

    static let `default` = CacheConfiguration(countryCacheTTL: 24 * 3600)
    static let testing   = CacheConfiguration(countryCacheTTL: 60)
}
