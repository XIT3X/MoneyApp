import Foundation

enum Currency: String, CaseIterable {
    case euro = "EUR"
    case dollar = "USD"
    case franc = "CHF"
    
    var symbol: String {
        switch self {
        case .euro:
            return "€"
        case .dollar:
            return "$"
        case .franc:
            return "CHF"
        }
    }
    
    var name: String {
        switch self {
        case .euro:
            return "Euro"
        case .dollar:
            return "Dollaro"
        case .franc:
            return "Franco"
        }
    }
    
    var flag: String {
        switch self {
        case .euro:
            return "🇪🇺"
        case .dollar:
            return "🇺🇸"
        case .franc:
            return "🇨🇭"
        }
    }
}

#if DEBUG
extension Currency {
    static var preview: Currency {
        return .euro
    }
}
#endif 