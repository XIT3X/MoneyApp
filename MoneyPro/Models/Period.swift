import Foundation

enum Period: String, CaseIterable {
    case from1st, from5th, from10th, from15th, from20th, from25th
    
    var displayName: String {
        switch self {
        case .from1st: return "Dal 1 del mese"
        case .from5th: return "Dal 5 del mese"
        case .from10th: return "Dal 10 del mese"
        case .from15th: return "Dal 15 del mese"
        case .from20th: return "Dal 20 del mese"
        case .from25th: return "Dal 25 del mese"
        }
    }
    
    func periodDescription(withMonthOffset offset: Int = 0) -> String {
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.day, from: now)
        let adjustedNow = calendar.date(byAdding: .month, value: offset, to: now) ?? now
        
        switch self {
        case .from1st:
            return formatMonthPeriod(for: adjustedNow)
        case .from5th:
            return formatCustomPeriod(day: 5, currentDay: currentDay, baseDate: adjustedNow)
        case .from10th:
            return formatCustomPeriod(day: 10, currentDay: currentDay, baseDate: adjustedNow)
        case .from15th:
            return formatCustomPeriod(day: 15, currentDay: currentDay, baseDate: adjustedNow)
        case .from20th:
            return formatCustomPeriod(day: 20, currentDay: currentDay, baseDate: adjustedNow)
        case .from25th:
            return formatCustomPeriod(day: 25, currentDay: currentDay, baseDate: adjustedNow)
        }
    }
    
    func getPeriodDates(day: Int, currentDay: Int, baseDate: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: baseDate) ?? baseDate
        let startDate = calendar.date(bySetting: .day, value: day, of: previousMonth) ?? baseDate
        let endDate = calendar.date(
            byAdding: .day,
            value: -1,
            to: calendar.date(bySetting: .day, value: day, of: baseDate) ?? baseDate
        ) ?? baseDate
        
        // Imposta l'ora di fine al 23:59:59 per includere tutto il giorno
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        return (startDate, endOfDay)
    }
    
    // MARK: - Private Methods
    private func formatMonthPeriod(for date: Date) -> String {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        let endDate = calendar.date(byAdding: .day, value: -1, to: endOfMonth) ?? date
        
        // Imposta l'ora di fine al 23:59:59 per includere tutto il giorno
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        return formatPeriodRange(start: startOfMonth, end: endOfDay)
    }
    
    private func formatCustomPeriod(day: Int, currentDay: Int, baseDate: Date) -> String {
        let (startDate, endDate) = getPeriodDates(day: day, currentDay: currentDay, baseDate: baseDate)
        return formatPeriodRange(start: startDate, end: endDate)
    }
    
    private func formatPeriodRange(start: Date, end: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        let startDay = calendar.component(.day, from: start)
        let endDay = calendar.component(.day, from: end)
        let startMonth = calendar.component(.month, from: start)
        let endMonth = calendar.component(.month, from: end)
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        
        // Check if it's a full month period
        if startDay == 1 && endDay == calendar.range(of: .day, in: .month, for: end)?.count {
            if startMonth == endMonth && startYear == endYear {
                let monthFormatter = DateFormatter()
                monthFormatter.locale = Locale(identifier: "it_IT")
                monthFormatter.dateFormat = "MMMM"
                let monthName = monthFormatter.string(from: start).capitalized
                
                // Add year if it's different from current year
                if startYear != currentYear {
                    return "\(monthName) \(startYear)"
                } else {
                    return monthName
                }
            }
        }
        
        // Standard range format
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d MMM"
        
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        
        // Add year to start date if it's different from current year
        var result = "\(startStr) - \(endStr)"
        if startYear != currentYear {
            result = "\(startStr) \(startYear) - \(endStr)"
        }
        
        return result
    }
}