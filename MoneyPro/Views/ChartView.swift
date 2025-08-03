import SwiftUI

// MARK: - Arc Shape
struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let clockwise: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        return path
    }
}



struct ChartView: View {
    @Binding var isPresented: Bool
    @StateObject private var transactionManager = TransactionManager()
    @StateObject private var settingsManager = SettingsManager()
    @State private var selectedMonthOffset: Int
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        let settingsManager = SettingsManager()
        self._selectedMonthOffset = State(initialValue: settingsManager.currentMonthOffset)
    }
    
    
    var body: some View {
        ZStack {
            // Background
            Colors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Period Selector
                periodSelector
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        categoryListView
                        
                        Spacer(minLength: 20)
                    }
                }
                .padding(.horizontal, 30)
            }
        }
        .onChange(of: settingsManager.currentMonthOffset) { _ in
            updateSelectedMonthOffset()
        }
        .onChange(of: settingsManager.selectedPeriod) { _ in
            updateSelectedMonthOffset()
        }
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        ZStack {
            // Gradiente di dissolvenza a sinistra
            HStack {
                LinearGradient(
                    gradient: Gradient(colors: [Colors.primaryBackground, Colors.primaryBackground.opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 30)
                
                Spacer()
            }
            
            // Gradiente di dissolvenza a destra
            HStack {
                Spacer()
                
                LinearGradient(
                    gradient: Gradient(colors: [Colors.primaryBackground.opacity(0), Colors.primaryBackground]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 30)
            }
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 60) {
                        ForEach(-24...24, id: \.self) { monthOffset in
                            let monthData = getMonthDataForOffset(monthOffset)
                            
                                                    VStack(spacing: 4) {
                            Text(monthData.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(monthData.isSelected ? Colors.primaryText : Colors.secondaryText)
                            
                            // Barra sotto il periodo selezionato
                            if monthData.isSelected {
                                Rectangle()
                                    .fill(Colors.primaryText)
                                    .frame(height: 3)
                                    .cornerRadius(1.5)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                        .id(monthOffset)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedMonthOffset = monthOffset
                                proxy.scrollTo(monthOffset, anchor: .center)
                            }
                        }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .onAppear {
                    // Posiziona il mese selezionato senza animazione
                    proxy.scrollTo(selectedMonthOffset, anchor: .center)
                }
                .onChange(of: selectedMonthOffset) { newValue in
                    // Centra automaticamente il mese selezionato quando cambia
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 40)
    }
    
    // MARK: - Comparison Bar View
    private var pieChartsView: some View {
        VStack(spacing: 16) {
            let totalExpenses = getTotalExpenses()
            let totalIncome = getTotalIncome()
            let totalBudget = totalExpenses + totalIncome
            let expensesPercentage = totalBudget > 0 ? (totalExpenses / totalBudget) * 100 : 0
            let incomePercentage = totalBudget > 0 ? (totalIncome / totalBudget) * 100 : 0
            
            HStack {
                Text("Spese")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Colors.secondaryText)
                
                Spacer()
                
                Text("Entrate")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Colors.secondaryText)
            }
            
            HStack(spacing: 0) {
                // Sezione spese (sinistra)
                Rectangle()
                    .fill(Colors.errorText)
                    .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(expensesPercentage / 100), height: 20)
                    .cornerRadius(10)
                
                // Sezione entrate (destra)
                Rectangle()
                    .fill(Colors.limeGreen)
                    .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(incomePercentage / 100), height: 20)
                    .cornerRadius(10)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            
            HStack(spacing: 20) {
                Text("\(Int(expensesPercentage))%")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Colors.secondaryText)
                
                Spacer()
                
                Text("\(Int(incomePercentage))%")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Colors.secondaryText)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Category List View
    private var categoryListView: some View {
        VStack(alignment: .leading, spacing: 7) {
            // Expenses Section
            expensesSection
            
            // Income Section
            incomeSection
        }
    }
    
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
                                HStack {
                Text("SPESE")
                    .font(AppFonts.headline2)
                    .foregroundColor(Colors.secondaryText)
                Spacer()
                Text("-\(String(format: "%.2f", getTotalExpenses())) €")
                    .font(AppFonts.headline2)
                    .foregroundColor(Colors.secondaryText)
            }
            .padding(.bottom, 8)
            .padding(.top, 22)
            
            // Divider tra la scritta e le categorie
            Rectangle()
                .fill(Colors.outlineColor)
                .frame(height: 1.2)
                .padding(.bottom, 14)
            
                            if getExpenseCategories().isEmpty {
                // Messaggio quando non ci sono spese
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down")
                        .rotationEffect(.degrees(-45))
                        .font(.system(size: 24))
                        .foregroundColor(Colors.secondaryText.opacity(0.6))
                    
                    Text("Nessuna spesa in questo periodo")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("Le tue spese appariranno qui quando\naggiungerai delle transazioni")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Colors.secondaryText.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    ForEach(getExpenseCategories()) { category in
                        CategoryRow(category: category, totalIncome: getTotalIncome())
                    }
                }
            }
        }
    }
    
    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
                                HStack {
                Text("ENTRATE")
                    .font(AppFonts.headline2)
                    .foregroundColor(Colors.secondaryText)
                Spacer()
                Text("+\(String(format: "%.2f", getTotalIncome())) €")
                    .font(AppFonts.headline2)
                    .foregroundColor(Colors.secondaryText)
            }
            .padding(.bottom, 8)
            .padding(.top, 28)
            
            // Divider tra la scritta e le categorie
            Rectangle()
                .fill(Colors.outlineColor)
                .frame(height: 1.2)
                .padding(.bottom, 14)
            
            if getIncomeCategories().isEmpty {
                // Messaggio quando non ci sono entrate
                VStack(spacing: 16) {
                    Image(systemName: "arrow.down")
                        .rotationEffect(.degrees(-135))
                        .font(.system(size: 24))
                        .foregroundColor(Colors.secondaryText.opacity(0.6))
                    
                    Text("Nessuna entrata in questo periodo")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("Le tue entrate appariranno qui quando\naggiungerai delle transazioni")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Colors.secondaryText.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    ForEach(getIncomeCategories()) { category in
                        CategoryRow(category: category, totalIncome: getTotalIncome())
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getMonthDataForOffset(_ monthOffset: Int) -> (name: String, isSelected: Bool) {
        let calendar = Calendar.current
        let now = Date()
        let adjustedNow = calendar.date(byAdding: .month, value: monthOffset, to: now) ?? now
        
        // Se è selezionato un periodo specifico (non dal 1 del mese), mostra il periodo
        if settingsManager.selectedPeriod != .from1st {
            let periodDescription = settingsManager.selectedPeriod.periodDescription(withMonthOffset: monthOffset)
            let isSelected = (monthOffset == selectedMonthOffset)
            return (name: periodDescription, isSelected: isSelected)
        } else {
            // Altrimenti mostra solo il mese
            let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: now) ?? now
            let monthName = getMonthName(for: monthDate)
            let isSelected = (monthOffset == selectedMonthOffset)
            
            return (name: monthName, isSelected: isSelected)
        }
    }
    
    private func updateSelectedMonthOffset() {
        // Aggiorna il selectedMonthOffset quando cambia il periodo nel MainView
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedMonthOffset = settingsManager.currentMonthOffset
        }
    }
    
    // MARK: - Data Calculation Methods
    private func getTotalExpenses() -> Double {
        let transactions = transactionManager.getTransactions(for: settingsManager.selectedPeriod, monthOffset: selectedMonthOffset)
        return transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }
    
    private func getExpenseCategories() -> [CategoryData] {
        let transactions = transactionManager.getTransactions(for: settingsManager.selectedPeriod, monthOffset: selectedMonthOffset)
        let expenseTransactions = transactions.filter { $0.amount < 0 }
        
        let totalExpenses = getTotalExpenses()
        
        var categoryMap: [String: (total: Double, count: Int)] = [:]
        
        for transaction in expenseTransactions {
            let categoryName = transaction.category
            categoryMap[categoryName, default: (0.0, 0)].total += abs(transaction.amount)
            categoryMap[categoryName, default: (0.0, 0)].count += 1
        }
        
        var categories: [CategoryData] = []
        for (name, data) in categoryMap {
            let percentage = totalExpenses > 0 ? (data.total / totalExpenses) * 100 : 0
            categories.append(CategoryData(name: name, iconName: getIconForCategory(name), totalAmount: data.total, transactionCount: data.count, percentage: percentage))
        }
        
        return categories.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private func getTotalIncome() -> Double {
        let transactions = transactionManager.getTransactions(for: settingsManager.selectedPeriod, monthOffset: selectedMonthOffset)
        return transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    private func getIncomeCategories() -> [CategoryData] {
        let transactions = transactionManager.getTransactions(for: settingsManager.selectedPeriod, monthOffset: selectedMonthOffset)
        let incomeTransactions = transactions.filter { $0.amount > 0 }
        
        var categoryMap: [String: (total: Double, count: Int)] = [:]
        
        for transaction in incomeTransactions {
            let categoryName = transaction.category
            categoryMap[categoryName, default: (0.0, 0)].total += transaction.amount
            categoryMap[categoryName, default: (0.0, 0)].count += 1
        }
        
        var categories: [CategoryData] = []
        for (name, data) in categoryMap {
            categories.append(CategoryData(name: name, iconName: getIconForCategory(name), totalAmount: data.total, transactionCount: data.count, percentage: nil)) // No percentage for income
        }
        
        return categories.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private func getIconForCategory(_ categoryName: String) -> String {
        return categoryEmoji(for: categoryName)
    }
    

    
    private func getMonthName(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let monthYear = calendar.component(.year, from: date)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: date).capitalized
        
        // Add year if it's different from current year
        if monthYear != currentYear {
            return "\(monthName) \(monthYear)"
        } else {
            return monthName
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Colors.primaryColor.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(Colors.primaryBackground)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            Spacer()
            
            Text("Statistiche")
                .font(AppFonts.headline)
                .foregroundColor(Colors.primaryText)
            
            Spacer()
            
            // Placeholder per bilanciare il layout
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

// MARK: - Helper Functions
private func getCategoryPercentage(_ category: CategoryData, totalIncome: Double) -> Double {
    if let percentage = category.percentage {
        // Per le spese, usa la percentuale esistente
        return percentage
    } else {
        // Per le entrate, calcola la percentuale rispetto al totale delle entrate
        if totalIncome > 0 {
            return (category.totalAmount / totalIncome) * 100
        }
        return 0
    }
}
private func getCategoryColor(_ categoryName: String) -> Color {
    switch categoryName.lowercased() {
    case "cibo": return Colors.categoriaCibo
    case "macchina": return Colors.categoriaMacchina
    case "svago": return Colors.categoriaSvago
    case "casa": return Colors.categoriaCasa
    case "shopping": return Colors.categoriaShopping
    case "salute": return Colors.categoriaSalute
    case "trasporti": return Colors.categoriaTrasporti
    case "sport": return Colors.categoriaSport
    case "viaggi": return Colors.categoriaViaggi
    case "animali": return Colors.categoriaAnimali
    case "spesa": return Colors.categoriaSpesa
    case "regali": return Colors.categoriaRegali
    case "stipendio": return Colors.categoriaStipendio
    case "regalo": return Colors.categoriaRegalo
    case "bonus": return Colors.categoriaBonus
    case "investimenti": return Colors.categoriaInvestimenti
    default: return Colors.limeGreen
    }
}



// MARK: - Supporting Structs
struct CategoryData: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let totalAmount: Double
    let transactionCount: Int
    let percentage: Double? // Optional for expenses
}

struct CategoryRow: View {
    let category: CategoryData
    let totalIncome: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 15) {
                // Emoji in quadrato
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Colors.outlineColor, lineWidth: 1)
                        .frame(width: 44, height: 44)
                    
                    Text(category.iconName)
                        .font(.system(size: 20))
                }
                .padding(.leading, 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.primaryText)
                    
                    Text("\(Int(getCategoryPercentage(category, totalIncome: totalIncome)))% del totale")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.2f", abs(category.totalAmount))) €")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.primaryText)
                    
                    Text("\(category.transactionCount) \(category.transactionCount == 1 ? "transazione" : "transazioni")")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                }
            }
            
                        // Barra della percentuale sotto ogni categoria
            HStack {
                Spacer()
                    .frame(width: 60)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Colors.outlineColor)
                            .frame(height: 6)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(getCategoryColor(category.name))
                            .frame(width: geometry.size.width * CGFloat(getCategoryPercentage(category, totalIncome: totalIncome) / 100.0), height: 6)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
#Preview {
    ChartView(isPresented: .constant(true))
}
#endif
