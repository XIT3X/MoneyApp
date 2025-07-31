import Foundation

class SettingsManager: ObservableObject {
    @Published var selectedPeriod: Period
    @Published var currentMonthOffset: Int
    @Published var showingWelcome: Bool
    
    private let userDefaults = UserDefaults.standard
    private let selectedPeriodKey = "selected_period_key"
    private let monthOffsetKey = "month_offset_key"
    private let welcomeKey = "hasSeenWelcome"
    
    init() {
        self.selectedPeriod = Self.loadSelectedPeriod()
        self.currentMonthOffset = Self.loadMonthOffset()
        self.showingWelcome = !userDefaults.bool(forKey: welcomeKey)
    }
    
    // MARK: - Public Methods
    func updatePeriod(_ period: Period) {
        selectedPeriod = period
        saveSelectedPeriod(period)
        // Non resettare l'offset del mese quando cambi periodo
    }
    
    func updateMonthOffset(_ offset: Int) {
        currentMonthOffset = offset
        saveMonthOffset(offset)
    }
    
    func markWelcomeAsSeen() {
        showingWelcome = false
        userDefaults.set(true, forKey: welcomeKey)
    }
    
    func resetToCurrentMonth() {
        currentMonthOffset = 0
        saveMonthOffset(0)
    }
    
    // MARK: - Private Methods
    private func saveSelectedPeriod(_ period: Period) {
        userDefaults.set(period.rawValue, forKey: selectedPeriodKey)
    }
    
    private func saveMonthOffset(_ offset: Int) {
        userDefaults.set(offset, forKey: monthOffsetKey)
    }
    
    private static func loadSelectedPeriod() -> Period {
        if let periodString = UserDefaults.standard.string(forKey: "selected_period_key"),
           let period = Period(rawValue: periodString) {
            return period
        }
        return .from1st
    }
    
    private static func loadMonthOffset() -> Int {
        return UserDefaults.standard.integer(forKey: "month_offset_key")
    }
}