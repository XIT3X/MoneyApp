import Foundation

class TransactionManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private let userDefaults = UserDefaults.standard
    private let transactionsKey = "transactions_key"
    
    init() {
        loadTransactions()
    }
    
    // MARK: - Public Methods
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveTransactions()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    func getTransactions(for period: Period, monthOffset: Int = 0) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let adjustedNow = calendar.date(byAdding: .month, value: monthOffset, to: now) ?? now
        let currentDay = calendar.component(.day, from: adjustedNow)
        
        switch period {
        case .from1st:
            return getMonthTransactions(for: adjustedNow)
        default:
            let day = getDayFromPeriod(period)
            let (startDate, endDate) = period.getPeriodDates(
                day: day,
                currentDay: currentDay,
                baseDate: adjustedNow
            )
            return transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
        }
    }
    
    func getUpcomingTransactions() -> [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        return transactions.filter { transaction in
            let transactionDay = calendar.startOfDay(for: transaction.date)
            return transactionDay > today
        }.sorted { $0.date < $1.date }
    }
    
    func getGroupedTransactions() -> [Date: [Transaction]] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        let pastTransactions = transactions.filter { transaction in
            let transactionDay = calendar.startOfDay(for: transaction.date)
            return transactionDay <= today
        }
        
        var grouped: [Date: [Transaction]] = [:]
        
        for transaction in pastTransactions.reversed() {
            let dateKey = transaction.date.stripTime
            grouped[dateKey, default: []].append(transaction)
        }
        
        return grouped
    }
    
    func processFutureTransactions() {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        let transactionsToProcess = transactions.filter { transaction in
            let transactionDay = calendar.startOfDay(for: transaction.date)
            return transactionDay <= today && transaction.date > now
        }
        
        if !transactionsToProcess.isEmpty {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    

    
    func getExpenses(for period: Period, monthOffset: Int = 0) -> Double {
        let filteredTransactions = getTransactions(for: period, monthOffset: monthOffset)
        return filteredTransactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    func getIncome(for period: Period, monthOffset: Int = 0) -> Double {
        let filteredTransactions = getTransactions(for: period, monthOffset: monthOffset)
        return filteredTransactions
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Private Methods
    private func loadTransactions() {
        guard let data = userDefaults.data(forKey: transactionsKey),
              let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: data) else {
            transactions = []
            return
        }
        transactions = decodedTransactions
    }
    
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            userDefaults.set(encoded, forKey: transactionsKey)
        }
    }
    
    private func getMonthTransactions(for date: Date) -> [Transaction] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        let endDate = calendar.date(byAdding: .day, value: -1, to: endOfMonth) ?? date
        
        // Imposta l'ora di fine al 23:59:59 per includere tutto il giorno
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        return transactions.filter { transaction in
            transaction.date >= startOfMonth && transaction.date <= endOfDay
        }
    }
    
    private func getDayFromPeriod(_ period: Period) -> Int {
        switch period {
        case .from1st: return 1
        case .from5th: return 5
        case .from10th: return 10
        case .from15th: return 15
        case .from20th: return 20
        case .from25th: return 25
        }
    }
}