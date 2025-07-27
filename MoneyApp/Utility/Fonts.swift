import SwiftUI

struct AppFonts {
    // SF Rounded Font Family
    static let sfRounded = "SF Rounded"
    
    // Font sizes
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let headline2 = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    
    // Custom sizes for specific use cases
    static let amountDisplay = Font.system(size: 48, weight: .medium, design: .rounded)
    static let amountSymbol = Font.system(size: 32, weight: .light, design: .rounded)
    static let numberPad = Font.system(size: 28, weight: .medium, design: .rounded)
    static let buttonText = Font.system(size: 18, weight: .medium, design: .rounded)
    static let detailText = Font.system(size: 18, weight: .regular, design: .rounded)
}

// Extension to make it easier to use
extension Font {
    static func sfRounded(_ size: CGFloat) -> Font {
        return Font.system(size: size, weight: .regular, design: .rounded)
    }
    
    static func sfRounded(_ size: CGFloat, weight: Font.Weight) -> Font {
        return Font.system(size: size, weight: weight, design: .rounded)
    }
} 
