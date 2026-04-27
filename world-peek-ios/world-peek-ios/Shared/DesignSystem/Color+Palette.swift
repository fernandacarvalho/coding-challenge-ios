import SwiftUI

extension Color {
    static let parchment = Color(hex: "f2ecea")
    static let blueGrey = Color(hex: "67a1d6")
    static let tangerineDream = Color(hex: "f78c5c")
    static let mutedTeal = Color(hex: "6e9e84")
    static let teaGreen = Color(hex: "d4dfaa")
}

private extension Color {
    init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
