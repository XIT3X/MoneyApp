import Foundation
import SwiftUI

// MARK: - Double Extensions
extension Double {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self)
    }
}

// MARK: - Date Extensions
extension Date {
    var formattedSection: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let selfDay = calendar.startOfDay(for: self)
        
        if selfDay == today {
            return "OGGI"
        } else if selfDay == yesterday {
            return "IERI"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            formatter.dateFormat = "EEEE, d MMMM"
            return formatter.string(from: self).uppercased()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: self)
    }
    
    var stripTime: Date {
        Calendar.current.startOfDay(for: self)
    }
}


// MARK: - Notification Names
extension Notification.Name {
    static let categoriesDidChange = Notification.Name("categoriesDidChange")
}

// MARK: - PreferenceKey for Scroll Offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}