import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Colors {
    
    //Test Color
    static let testColor1 = Color(red: 100, green: 0, blue: 0)
    static let testColor2 = Color(red: 0, green: 100, blue: 0)
    
    // Background Colors
    static let primaryBackground = Color(hex: "#FFFFFF")
    static let secondaryBackground = Color(hex: "#f6f6f6")
    
    // Text Colors
    static let primaryText = Color(hex: "#121212")
    static let secondaryText = Color(hex: "#a6a6a6")
    
    // Outline Colors
    static let outlineColor = Color(hex: "#ecf0f4")

    // Accent Colors
    static let primaryColor = Color(hex: "#3c3c3c")
    
    // Extra Color
    static let error = Color(hex: "#ffd4d1")
    static let errorText = Color(hex: "#fe473a")
    static let incoming = Color(hex: "#00B4D8")

    static let categoriaCibo = Color(hex: "#FF6B6B")
    static let categoriaMacchina = Color(hex: "#45B7D1")
    static let categoriaSvago = Color(hex: "#4ECDC4")
    static let categoriaCasa = Color(hex: "#96CEB4")
    static let categoriaShopping = Color(hex: "#FF8C42")
    static let categoriaSalute = Color(hex: "#DDA0DD")
    static let categoriaStipendio = Color(hex: "#FDCB6E")
    static let categoriaRegalo = Color(hex: "#A29BFE")
    static let categoriaBonus = Color(hex: "#FD79A8")
    static let categoriaBonus2 = Color(hex: "#00B894")
}
