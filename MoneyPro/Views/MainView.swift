import SwiftUI

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Notifiche
// categoriesDidChange is defined in NewTransactionView.swift

// Struttura per tenere traccia delle percentuali delle categorie
struct CategoryPercentage {
    let category: String
    let amount: Double
    let percentage: Double
}

struct MainView: View {
    @StateObject private var coreDataManager = CoreDataManager.shared
    @StateObject private var backupService = BackupService.shared
    
    @State private var transactions: [Transaction] = []
    @State private var showingNewTransaction = false
    @State private var transactionToEdit: Transaction?
    @State private var selectedPeriod: Period = .from1st
    @State private var currentPeriodIndex: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var futureCheckTimer: Timer?
    @State private var currentMonthOffset: Int = 0 // Offset per il mese corrente
    @State private var dragOffset: CGFloat = 0 // Offset di trascinamento per lo slider
    @State private var baseMonthOffset: Int = 0 // Offset base quando inizia il trascinamento
    @State private var showingSettings = false
    @State private var showingWelcome = false
    
    // Chiavi per salvare il periodo selezionato e l'offset del mese
    private let selectedPeriodKey = "selected_period_key"
    private let monthOffsetKey = "month_offset_key"
    
    // Variabili per l'effetto onde
    @State private var waveScale: [CGFloat] = [1.0, 1.0, 1.0]
    @State private var waveOpacity: [Double] = [0.7, 0.7, 0.7]
    
    init() {
        _selectedPeriod = State(initialValue: Self.loadSelectedPeriod())
        _currentMonthOffset = State(initialValue: Self.loadMonthOffset())
        
        // Controlla se è la prima apertura dell'app
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
        _showingWelcome = State(initialValue: !hasSeenWelcome)
    }
    
    // Funzione per avviare l'animazione delle onde
    private func startWaveAnimation() {
        for i in 0..<1 {
            withAnimation(
                Animation.easeOut(duration: 2.5)
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 2.5)
            ) {
                waveScale[i] = 2.5
                waveOpacity[i] = 0.0
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { 
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            showingSettings = true 
                        }) {
                            Image("ic_options")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foregroundColor(Colors.secondaryText)
                                .frame(width: 44, height: 44)
                                .background(Colors.primaryBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Colors.outlineColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        Spacer()
                        VStack(spacing: 2) {
                            Text("Periodo")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Colors.secondaryText)
                            Menu {
                                ForEach(Period.allCases, id: \.self) { period in
                                    Button(period.displayName) {
                                        selectedPeriod = period
                                        if let index = availablePeriods.firstIndex(of: period) {
                                            currentPeriodIndex = index
                                        }
                                        currentMonthOffset = 0
                                        saveMonthOffset(currentMonthOffset)
                                        // Salva il periodo selezionato
                                        saveSelectedPeriod(period)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedPeriod.displayName)
                                        .font(AppFonts.headline)
                                        .foregroundColor(Colors.primaryText)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Colors.secondaryText)
                                }
                            }
                        }
                        Spacer()
                        Button(action: { 
                            // Vibrazione leggera all'apertura
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            showingNewTransaction = true 
                        }) {
                            ZStack {
                                // Effetto onde
                                if transactions.isEmpty {
                                    ForEach(0..<1, id: \.self) { index in
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Colors.outlineColor.opacity(0.8), lineWidth: 4)
                                            .frame(width: 44 + CGFloat(index * 10), height: 44 + CGFloat(index * 10))
                                            .scaleEffect(waveScale[index])
                                            .opacity(waveOpacity[index])
                                    }
                                }
                                
                                // Bottone +
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Colors.secondaryText)
                                    .frame(width: 44, height: 44)
                                    .background(Colors.primaryBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Colors.outlineColor, lineWidth: 1)
                                    )
                            }
                            .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Colors.primaryBackground)
                    // Divisore (ora non visibile)
                    Rectangle()
                        .fill(Colors.outlineColor)
                        .frame(height: 1.2)
                        .opacity(0)
                }
                // ScrollView
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        if transactions.isEmpty {
                            // Messaggio quando non ci sono transazioni
                            VStack(spacing: 0) {
                                Spacer()
                                
                                // Icona
                                Image("empty_icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Colors.secondaryText.opacity(0.3))
                                    .padding(.bottom, 24)
                                    .padding(.leading, 8)
                                
                                // Testo principale
                                Text("Non c'è nulla qui...")
                                    .font(.system(size: 24, weight: .medium, design: .rounded))
                                    .foregroundColor(Colors.primaryText)
                                    .padding(.bottom, 12)
                                
                                // Testo secondario
                                VStack(spacing: 0) {
                                    Text("Aggiungi la tua prima transazione")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Colors.secondaryText)
                                        .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 6) {
                                        Text("toccando il pulsante")
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundColor(Colors.secondaryText)
                                        
                                        Image(systemName: "plus")
                                            .padding(.bottom, 0.5)
                                            .padding(.leading, 0.7)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Colors.secondaryText)
                                            .frame(width: 22, height: 22)
                                            .background(Colors.primaryBackground)
                                            .cornerRadius(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Colors.outlineColor, lineWidth: 1).opacity(5)
                                            )
                                            .padding(.top, 2)
                                        
                                        Text("in alto")
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundColor(Colors.secondaryText)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 500)
                        } else {
                            // Sezione Cifra Totale
                            VStack(spacing: 0) {
                                Text(selectedPeriod.periodDescription(withMonthOffset: currentMonthOffset))
                                    .font(AppFonts.headline2)
                                    .foregroundColor(Colors.secondaryText)
                                    .padding(.bottom, 8)
                                HStack(alignment: .center, spacing: 4) {
                                    if netTotal < 0 {
                                        Text("-")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundColor(Colors.secondaryText)
                                    }
                                    Text(abs(netTotal).formattedAmount)
                                        .font(AppFonts.amountDisplay)
                                        .fontWeight(.medium)
                                        .foregroundColor(Colors.primaryText)
                                    Text("€")
                                        .font(AppFonts.amountSymbol)
                                        .foregroundColor(Colors.secondaryText)
                                }
                            }
                            .padding(.vertical, 40)
                            .offset(x: dragOffset * 0.1) // Effetto slider durante il trascinamento
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation.width
                                    }
                                    .onEnded { value in
                                        let threshold: CGFloat = 80
                                        let translation = value.translation.width
                                        
                                        // Calcola il cambio di mese in modo più preciso
                                        if translation > threshold {
                                            // Trascinamento verso destra - mese precedente
                                            currentMonthOffset -= 1
                                            saveMonthOffset(currentMonthOffset)
                                        } else if translation < -threshold {
                                            // Trascinamento verso sinistra - mese successivo
                                            currentMonthOffset += 1
                                            saveMonthOffset(currentMonthOffset)
                                        }
                                        
                                        dragOffset = 0
                                    }
                            )
                            //Barra Categorie
                            CategoryDistributionBar(transactions: filteredTransactions)
                                .id("categorySection")
                            
                            // Sezione In Futuro
                            VStack(alignment: .leading, spacing: 0) {
                                let upcoming = upcomingTransactions
                                if !upcoming.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        SectionHeader(title: "IN FUTURO", isFuture: true)
                                        ForEach(upcoming) { tx in
                                            TransactionRow(transaction: tx, isFuture: true) {
                                                // Vibrazione leggera quando si preme per modificare
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                                transactionToEdit = tx
                                                showingNewTransaction = true
                                            }
                                        }
                                    }
                                }
                                ForEach(groupedTransactions.keys.sorted(by: >), id: \ .self) { date in
                                    let dayTxs = groupedTransactions[date] ?? []
                                    let dayBalance = dayTxs.reduce(0) { $0 + $1.amount }
                                    SectionHeader(title: date.formattedSection, balance: dayBalance, isFuture: false)
                                    ForEach(dayTxs) { tx in
                                        TransactionRow(transaction: tx, isFuture: false) {
                                            // Vibrazione leggera quando si preme per modificare
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                            transactionToEdit = tx
                                            showingNewTransaction = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }


                }
            }
            .background(Colors.primaryBackground)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showingNewTransaction) {
                NewTransactionView(transactionToEdit: transactionToEdit) { [self] newTransaction in
                    if let editingTransaction = transactionToEdit {
                        // Modifica transazione esistente
                        self.updateTransaction(newTransaction)
                    } else {
                        // Aggiungi nuova transazione
                        self.saveTransaction(newTransaction)
                    }
                    transactionToEdit = nil
                    showingNewTransaction = false
                } onDelete: { [self] in
                    // Elimina transazione
                    if let editingTransaction = transactionToEdit {
                        self.deleteTransaction(editingTransaction)
                    }
                    transactionToEdit = nil
                    showingNewTransaction = false
                }
            }
            .fullScreenCover(isPresented: $showingSettings) {
                SettingView(isPresented: $showingSettings) {
                    showingSettings = false
                }
            }
            .fullScreenCover(isPresented: $showingWelcome) {
                WelcomeView(isPresented: $showingWelcome) {
                    showingWelcome = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.transactions = self.coreDataManager.loadTransactions()
                // Controlla le transazioni future quando l'app torna in foreground
                processFutureTransactions()
                // Reset dell'offset del mese quando l'app torna in foreground
                currentMonthOffset = 0
                saveMonthOffset(currentMonthOffset)
            }
            .onAppear {
                // I dati vengono caricati in loadDataAndMigrate()
                // Inizializza l'indice del periodo corrente
                if let index = availablePeriods.firstIndex(of: selectedPeriod) {
                    currentPeriodIndex = index
                }
                // Avvia l'animazione delle onde se non ci sono transazioni
                if transactions.isEmpty {
                    startWaveAnimation()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .categoriesDidChange)) { _ in
                self.transactions = self.coreDataManager.loadTransactions()
            }
            .onChange(of: transactions.isEmpty) { _, isEmpty in
                if isEmpty {
                    startWaveAnimation()
                }
                // Non serve più resettare le onde perché vengono rimosse dal DOM
            }
            .onAppear { [self] in
                self.loadDataAndMigrate()
                startFutureTransactionCheck()
            }
            .onDisappear {
                stopFutureTransactionCheck()
            }
        }
    }

    // MARK: - Computed
    private var availablePeriods: [Period] {
        [.from1st, .from5th, .from10th, .from15th, .from20th, .from25th]
    }
    
    private var netTotal: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    private var totalIncome: Double {
        filteredTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    private var totalExpense: Double {
        abs(filteredTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let adjustedNow = calendar.date(byAdding: .month, value: currentMonthOffset, to: now) ?? now
        let currentDay = calendar.component(.day, from: adjustedNow)
        
        switch selectedPeriod {
        case .from1st:
            let startOfMonth = calendar.dateInterval(of: .month, for: adjustedNow)?.start ?? adjustedNow
            let endOfMonth = calendar.dateInterval(of: .month, for: adjustedNow)?.end ?? adjustedNow
            let endDate = calendar.date(byAdding: .day, value: -1, to: endOfMonth) ?? adjustedNow
            return transactions.filter { transaction in
                transaction.date >= startOfMonth && transaction.date <= endDate
            }
            
        case .from5th:
            let (startDate, endDate) = selectedPeriod.getPeriodDates(day: 5, currentDay: currentDay, baseDate: adjustedNow)
            return transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
            
        case .from10th:
            let (startDate, endDate) = selectedPeriod.getPeriodDates(day: 10, currentDay: currentDay, baseDate: adjustedNow)
            return transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
            
        case .from15th:
            let (startDate, endDate) = selectedPeriod.getPeriodDates(day: 15, currentDay: currentDay, baseDate: adjustedNow)
            return transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
            
        case .from20th:
            let (startDate, endDate) = selectedPeriod.getPeriodDates(day: 20, currentDay: currentDay, baseDate: adjustedNow)
            return transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
            
        case .from25th:
            let (startDate, endDate) = selectedPeriod.getPeriodDates(day: 25, currentDay: currentDay, baseDate: adjustedNow)
            return transactions.filter { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            }
        }
    }
    
    private var upcomingTransactions: [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        return transactions.filter { transaction in
            let transactionDay = calendar.startOfDay(for: transaction.date)
            // Mostra solo transazioni future (giorno successivo a oggi)
            return transactionDay > today
        }.sorted { $0.date < $1.date }
    }
    private var groupedTransactions: [Date: [Transaction]] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        // Include tutte le transazioni fino a oggi (incluso oggi)
        let past = transactions.filter { transaction in
            let transactionDay = calendar.startOfDay(for: transaction.date)
            return transactionDay <= today
        }
        
        // Raggruppa mantenendo l'ordine originale (più recenti in alto)
        var grouped: [Date: [Transaction]] = [:]
        
        for transaction in past.reversed() {
            let dateKey = transaction.date.stripTime
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(transaction)
        }
        
        return grouped
    }

    // MARK: - Persistence
    // La persistenza è ora gestita da Core Data
    
    private func saveSelectedPeriod(_ period: Period) {
        UserDefaults.standard.set(period.rawValue, forKey: selectedPeriodKey)
    }
    
    private func saveMonthOffset(_ offset: Int) {
        UserDefaults.standard.set(offset, forKey: monthOffsetKey)
    }
    
    static private func loadSelectedPeriod() -> Period {
        if let periodString = UserDefaults.standard.string(forKey: "selected_period_key"),
           let period = Period(rawValue: periodString) {
            return period
        }
        return .from1st // Default se non c'è un periodo salvato
    }
    
    static private func loadMonthOffset() -> Int {
        // Sempre restituisce 0 per mostrare il mese corrente di default
        return 0
    }
    

    
    // La funzione loadTransactions è ora gestita da Core Data
    
    // MARK: - Future Transaction Management
    private func startFutureTransactionCheck() {
        // Controlla immediatamente le transazioni future
        processFutureTransactions()
        
        // Imposta un timer che controlla ogni minuto
        futureCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            processFutureTransactions()
        }
    }
    
    private func stopFutureTransactionCheck() {
        futureCheckTimer?.invalidate()
        futureCheckTimer = nil
    }
    
    private func processFutureTransactions() {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        
        // Trova le transazioni future che sono diventate passate
        let transactionsToProcess = transactions.filter { transaction in
            let transactionDay = calendar.startOfDay(for: transaction.date)
            return transactionDay <= today && transaction.date > now
        }
        
        // Se ci sono transazioni da processare, aggiorna la lista
        if !transactionsToProcess.isEmpty {
            // Le transazioni rimangono nella lista ma ora saranno mostrate nello storico
            // perché la loro data è passata
            DispatchQueue.main.async {
                // Ricarica le transazioni per assicurarsi che l'UI si aggiorni
                self.transactions = self.coreDataManager.loadTransactions()
            }
        }
    }
}

// MARK: - Helpers

struct SectionHeader: View {
    let title: String
    let balance: Double?
    let isFuture: Bool
    
    init(title: String, balance: Double? = nil, isFuture: Bool = false) {
        self.title = title
        self.balance = balance
        self.isFuture = isFuture
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(AppFonts.headline2)
                    .foregroundColor(Colors.secondaryText)
                Spacer()
                if let balance = balance {
                    Text(balance.formattedAmount + " €")
                        .font(AppFonts.headline2)
                        .foregroundColor(Colors.secondaryText)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 25)
            .padding(.bottom, 5.5)
            
            Rectangle()
                .fill(Colors.outlineColor)
                .frame(height: 1.2)
                .padding(.horizontal, 30)
                .padding(.bottom, 7.5)
                .opacity(isFuture ? 1.0 : 1.0) // Il divisore non è mai opacizzato
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let isFuture: Bool
    let onTap: (() -> Void)?
    
    init(transaction: Transaction, isFuture: Bool = false, onTap: (() -> Void)? = nil) {
        self.transaction = transaction
        self.isFuture = isFuture
        self.onTap = onTap
    }
    
    var body: some View {
        // Contenuto della transazione
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isFuture ? Colors.primaryBackground : categoryColor(for: transaction.category).opacity(0.75))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isFuture ? categoryColor(for: transaction.category) : Color.clear, lineWidth: isFuture ? 2 : 0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Colors.outlineColor, lineWidth: isFuture ? 0 : 1)
                        )
                        .opacity(isFuture ? 0.6 : 1.0)
                        
                    Text(categoryEmoji(for: transaction.category))
                        .font(.system(size: 20))
                        .opacity(isFuture ? 0.6 : 1.0)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.description.isEmpty ? transaction.category : transaction.description)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(isFuture ? Colors.secondaryText : Colors.primaryText)
                    Text(isFuture ? transaction.date.formattedDate : transaction.category)
                        .fontWeight(.medium)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                }
                Spacer()
                Text((transaction.amount >= 0 ? "+" : "") + transaction.amount.formattedAmount + " €")
                    .fontWeight(.semibold)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundColor(isFuture ? Colors.secondaryText : (transaction.amount >= 0 ? .green : Colors.primaryText))
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
            .padding(.top, 10)
            .background(Colors.primaryBackground)
            .onTapGesture {
                onTap?()
            }
        
    }
}

// MARK: - Utility

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
            formatter.dateFormat = "EEEE, d MMMM" // es: "mercoledì, 23 luglio"
            return formatter.string(from: self).uppercased()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d MMM yyyy" // es: "23 lug 2024"
        return formatter.string(from: self)
    }
    
    var stripTime: Date {
        let cal = Calendar.current
        return cal.startOfDay(for: self)
    }
}

// MARK: - Categoria emoji/color
func categoryEmoji(for category: String) -> String {
    // Prima controlla le categorie personalizzate
    if let customCategory = findCustomCategory(by: category) {
        return customCategory.emoji
    }
    
    // Poi le categorie predefinite
    switch category.lowercased() {
    case "cibo": return "🍖"
    case "macchina": return "🚙"
    case "svago": return "🍿"
    case "casa": return "🏡"
    case "shopping": return "🛍️"
    case "salute": return "🫀"
    case "stipendio": return "💼"
    case "regalo": return "🎁"
    case "bonus": return "💸"
    default: return "🏷️"
    }
}

func categoryColor(for category: String) -> Color {
    // Prima controlla le categorie personalizzate
    if let customCategory = findCustomCategory(by: category) {
        return customCategory.color
    }
    
    // Poi le categorie predefinite
    switch category.lowercased() {
    case "cibo": return Colors.categoriaCibo
    case "macchina": return Colors.categoriaMacchina
    case "svago": return Colors.categoriaSvago
    case "casa": return Colors.categoriaCasa
    case "shopping": return Colors.categoriaShopping
    case "salute": return Colors.categoriaSalute
    case "stipendio": return Colors.categoriaStipendio
    case "regalo": return Colors.categoriaRegalo
    case "bonus": return Colors.categoriaBonus
    default: return Colors.primaryColor
    }
}

// MARK: - Utility per categorie personalizzate
func findCustomCategory(by name: String) -> CategoryItem? {
    // Carica tutte le categorie personalizzate
    let allCustomCategories = loadCustomCategories()
    
    // Cerca la categoria per nome (case insensitive)
    return allCustomCategories.first { $0.name.lowercased() == name.lowercased() }
}

func loadCustomCategories() -> [CategoryItem] {
    var allCategories: [CategoryItem] = []
    
    // Carica le categorie spese personalizzate
    if let expenseData = UserDefaults.standard.array(forKey: "customExpenseCategories") as? [[String: Any]] {
        let expenseCategories: [CategoryItem] = expenseData.compactMap { data in
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = data["name"] as? String,
                  let colorHex = data["colorHex"] as? String,
                  let emoji = data["emoji"] as? String else {
                return nil
            }
            
            return CategoryItem(
                id: id,
                name: name,
                color: hexToColor(colorHex),
                emoji: emoji
            )
        }
        allCategories.append(contentsOf: expenseCategories)
    }
    
    // Carica le categorie entrate personalizzate
    if let incomeData = UserDefaults.standard.array(forKey: "customIncomeCategories") as? [[String: Any]] {
        let incomeCategories: [CategoryItem] = incomeData.compactMap { data in
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = data["name"] as? String,
                  let colorHex = data["colorHex"] as? String,
                  let emoji = data["emoji"] as? String else {
                return nil
            }
            
            return CategoryItem(
                id: id,
                name: name,
                color: hexToColor(colorHex),
                emoji: emoji
            )
        }
        allCategories.append(contentsOf: incomeCategories)
    }
    
    return allCategories
}

func hexToColor(_ hex: String) -> Color {
    // Converti hex in Color
    switch hex {
    case "#ffbeaa": return Colors.categoriaCibo
    case "#9acdf9": return Colors.categoriaMacchina
    case "#addab0": return Colors.categoriaSvago
    case "#ffd08c": return Colors.categoriaCasa
    case "#f499b7": return Colors.categoriaShopping
    case "#f9aaa5": return Colors.categoriaSalute
    case "#c0b2ab": return Colors.categoriaStipendio
    case "#cfbee7": return Colors.categoriaRegalo
    case "#d19eda": return Colors.categoriaBonus
    case "#9ed7da": return Colors.categoriaBonus2
    case "#00B4D8": return Colors.incoming
    default: return Colors.categoriaCibo
    }
}



// MARK: - Periodo

enum Period: String, CaseIterable {
    case from1st, from5th, from10th, from15th, from20th, from25th
    
    var displayName: String {
        switch self {
        case .from1st: return "dal 1 del mese"
        case .from5th: return "dal 5 del mese"
        case .from10th: return "dal 10 del mese"
        case .from15th: return "dal 15 del mese"
        case .from20th: return "dal 20 del mese"
        case .from25th: return "dal 25 del mese"
        }
    }
    
    func periodDescription(withMonthOffset offset: Int = 0) -> String {
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.day, from: now)
        
        // Applica l'offset del mese se disponibile
        let adjustedNow = calendar.date(byAdding: .month, value: offset, to: now) ?? now
        
        switch self {
        case .from1st:
            let startOfMonth = calendar.dateInterval(of: .month, for: adjustedNow)?.start ?? adjustedNow
            let endOfMonth = calendar.dateInterval(of: .month, for: adjustedNow)?.end ?? adjustedNow
            let endDate = calendar.date(byAdding: .day, value: -1, to: endOfMonth) ?? adjustedNow
            return formatPeriodRange(start: startOfMonth, end: endDate)
            
        case .from5th:
            let (startDate, endDate) = getPeriodDates(day: 5, currentDay: currentDay, baseDate: adjustedNow)
            return formatPeriodRange(start: startDate, end: endDate)
            
        case .from10th:
            let (startDate, endDate) = getPeriodDates(day: 10, currentDay: currentDay, baseDate: adjustedNow)
            return formatPeriodRange(start: startDate, end: endDate)
            
        case .from15th:
            let (startDate, endDate) = getPeriodDates(day: 15, currentDay: currentDay, baseDate: adjustedNow)
            return formatPeriodRange(start: startDate, end: endDate)
            
        case .from20th:
            let (startDate, endDate) = getPeriodDates(day: 20, currentDay: currentDay, baseDate: adjustedNow)
            return formatPeriodRange(start: startDate, end: endDate)
            
        case .from25th:
            let (startDate, endDate) = getPeriodDates(day: 25, currentDay: currentDay, baseDate: adjustedNow)
            return formatPeriodRange(start: startDate, end: endDate)
        }
    }
    
    func getPeriodDates(day: Int, currentDay: Int, baseDate: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let adjustedCurrentDay = calendar.component(.day, from: baseDate)
        
        // Sempre dal giorno del mese precedente al giorno precedente del mese corrente
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: baseDate) ?? baseDate
        let startDate = calendar.date(bySetting: .day, value: day, of: previousMonth) ?? baseDate
        let endDate = calendar.date(byAdding: .day, value: -1, to: calendar.date(bySetting: .day, value: day, of: baseDate) ?? baseDate) ?? baseDate
        return (startDate, endDate)
    }
    
    private func formatPeriodRange(start: Date, end: Date) -> String {
        let calendar = Calendar.current
        
        // Controlla se il periodo copre l'intero mese (dal 1° all'ultimo giorno)
        let startDay = calendar.component(.day, from: start)
        let endDay = calendar.component(.day, from: end)
        let startMonth = calendar.component(.month, from: start)
        let endMonth = calendar.component(.month, from: end)
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        
        // Se inizia il 1° del mese e finisce l'ultimo giorno del mese
        if startDay == 1 && endDay == calendar.range(of: .day, in: .month, for: end)?.count {
            // Se è lo stesso mese e anno, mostra solo il nome del mese
            if startMonth == endMonth && startYear == endYear {
                let monthFormatter = DateFormatter()
                monthFormatter.locale = Locale(identifier: "it_IT")
                monthFormatter.dateFormat = "MMMM"
                return monthFormatter.string(from: start).capitalized
            }
        }
        
        // Altrimenti mostra il range normale
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d MMM"
        
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        
        return "\(startStr) - \(endStr)"
    }
}

// MARK: - MainView Extensions

extension MainView {
    // MARK: - Gestione Dati Core Data
    
    private func loadDataAndMigrate() {
        // Controlla se è la prima volta che si usa Core Data
        let hasMigrated = UserDefaults.standard.bool(forKey: "hasMigratedToCoreData")
        
        if !hasMigrated {
            // Migra i dati da UserDefaults a Core Data
            self.backupService.migrateFromUserDefaults()
            UserDefaults.standard.set(true, forKey: "hasMigratedToCoreData")
        }
        
        // Carica le transazioni da Core Data
        self.transactions = self.coreDataManager.loadTransactions()
        
        // Crea un backup automatico
        self.backupService.createAutomaticBackup()
    }
    
    private func saveTransaction(_ transaction: Transaction) {
        self.coreDataManager.saveTransaction(transaction)
        self.transactions = self.coreDataManager.loadTransactions()
        self.backupService.createAutomaticBackup()
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        self.coreDataManager.deleteTransaction(transaction)
        self.transactions = self.coreDataManager.loadTransactions()
        self.backupService.createAutomaticBackup()
    }
    
    private func updateTransaction(_ transaction: Transaction) {
        self.coreDataManager.updateTransaction(transaction)
        self.transactions = self.coreDataManager.loadTransactions()
        self.backupService.createAutomaticBackup()
    }
    
    // MARK: - Funzioni Legacy (mantenute per compatibilità)
    
    private static func loadTransactions() -> [Transaction] {
        return CoreDataManager.shared.loadTransactions()
    }
    
    private func saveTransactions() {
        // Questa funzione è ora gestita da Core Data
        self.backupService.createAutomaticBackup()
    }
    
    // MARK: - Category Flow Layout
    struct CategoryFlowLayout: Layout {
        let spacing: CGFloat
        
        init(spacing: CGFloat = 8) {
            self.spacing = spacing
        }
        
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let result = FlowResult(
                in: proposal.replacingUnspecifiedDimensions().width,
                subviews: subviews,
                spacing: spacing
            )
            return result.size
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let result = FlowResult(
                in: bounds.width,
                subviews: subviews,
                spacing: spacing
            )
            
            for (index, subview) in subviews.enumerated() {
                let point = result.positions[index]
                subview.place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
            }
        }
        
        struct FlowResult {
            let positions: [CGPoint]
            let size: CGSize
            
            init(in availableWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
                var positions: [CGPoint] = []
                var currentPosition = CGPoint.zero
                var lineHeight: CGFloat = 0
                var maxLineWidth: CGFloat = 0
                
                for subview in subviews {
                    let size = subview.sizeThatFits(.unspecified)
                    
                    // Se questo elemento non ci sta nella riga corrente, vai a capo
                    if currentPosition.x + size.width > availableWidth && currentPosition.x > 0 {
                        currentPosition.x = 0
                        currentPosition.y += lineHeight + spacing
                        lineHeight = 0
                    }
                    
                    positions.append(currentPosition)
                    currentPosition.x += size.width + spacing
                    lineHeight = max(lineHeight, size.height)
                    maxLineWidth = max(maxLineWidth, currentPosition.x - spacing)
                }
                
                self.positions = positions
                self.size = CGSize(width: availableWidth, height: currentPosition.y + lineHeight)
            }
        }
    }

}

// MARK: - BARRA DELLE CATEGORIE
struct CategoryDistributionBar: View {
    let transactions: [Transaction]
    
    
    private var totalExpense: Double {
        abs(transactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    
    
    
    var body: some View {
        TabView {
            // SEZIONE SPESE
            VStack(spacing: 8) {
                // Titolo e totale spese
                HStack {
                    Text("Spese")
                        .font(AppFonts.headline2)
                        .foregroundColor(Colors.secondaryText)
                    Spacer()
                    Text(totalExpense.formattedAmount + " €")
                        .font(AppFonts.headline2)
                        .foregroundColor(Colors.secondaryText)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 4)
                
                if !categoryPercentages.isEmpty {
                    GeometryReader { geometry in
                        HStack(spacing: 5) {
                            ForEach(categoryPercentages, id: \.category) { item in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(categoryColor(for: item.category))
                                    .frame(width: (geometry.size.width - CGFloat(categoryPercentages.count - 1) * 5) * item.percentage, height: 30)
                                    .animation(.easeInOut(duration: 0.3), value: item.percentage)
                            }
                        }
                        .frame(height: 30)
                        .cornerRadius(6)
                        .clipped()
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 30)
                    
                    // Lista delle categorie - Slider orizzontale
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categoryPercentages, id: \.category) { item in
                                HStack(spacing: 6) {
                                    // Quadratino colorato
                                    Rectangle()
                                        .fill(categoryColor(for: item.category))
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(4)
                                    
                                    // Nome categoria
                                    Text(item.category)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Colors.primaryText)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                    
                                    // Percentuale
                                    Text("\(Int(item.percentage * 100))%")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Colors.secondaryText)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Colors.primaryBackground)
                                .cornerRadius(8)
                                
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 6)
                } else {
                    // Barra vuota quando non ci sono spese
                    Rectangle()
                        .fill(Colors.outlineColor.opacity(0.3))
                        .frame(height: 30)
                        .cornerRadius(6)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 6)
                    
                    // Messaggio sotto la barra
                    Text("Nessuna spesa in questo periodo")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                        .padding(.top, 6)
                        .padding(.horizontal, 30)
                }
            }
            .tag(0)
            
            // SEZIONE ENTRATE
            VStack(spacing: 8) {
                // Titolo e totale entrate
                HStack {
                    Text("Entrate")
                        .font(AppFonts.headline2)
                        .foregroundColor(Colors.secondaryText)
                    Spacer()
                    Text(totalIncome.formattedAmount + " €")
                        .font(AppFonts.headline2)
                        .foregroundColor(Colors.secondaryText)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 4)
                
                if !incomeCategoryPercentages.isEmpty {
                    GeometryReader { geometry in
                        HStack(spacing: 5) {
                            ForEach(incomeCategoryPercentages, id: \.category) { item in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(categoryColor(for: item.category))
                                    .frame(width: (geometry.size.width - CGFloat(incomeCategoryPercentages.count - 1) * 5) * item.percentage, height: 30)
                                    .animation(.easeInOut(duration: 0.3), value: item.percentage)
                            }
                        }
                        .frame(height: 30)
                        .cornerRadius(6)
                        .clipped()
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 30)
                    
                    // Lista delle categorie entrate - Slider orizzontale
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(incomeCategoryPercentages, id: \.category) { item in
                                HStack(spacing: 6) {
                                    // Quadratino colorato
                                    Rectangle()
                                        .fill(categoryColor(for: item.category))
                                        .frame(width: 12, height: 12)
                                        .cornerRadius(4)
                                    
                                    // Nome categoria
                                    Text(item.category)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Colors.primaryText)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                    
                                    // Percentuale
                                    Text("\(Int(item.percentage * 100))%")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Colors.secondaryText)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Colors.primaryBackground)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 6)
                } else {
                    // Barra vuota quando non ci sono entrate
                    Rectangle()
                        .fill(Colors.outlineColor.opacity(0.3))
                        .frame(height: 30)
                        .cornerRadius(6)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 6)
                    
                    // Messaggio sotto la barra
                    Text("Nessuna entrata in questo periodo")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                        .padding(.top, 6)
                        .padding(.horizontal, 30)
                }
            }
            .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 108)
    }
    
    // Calcola le percentuali delle categorie
    private var categoryPercentages: [CategoryPercentage] {
        let totalExpense = abs(transactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
        
        if totalExpense == 0 { return [] }
        
        // Raggruppa le spese per categoria
        var categoryTotals: [String: Double] = [:]
        for transaction in transactions where transaction.amount < 0 {
            let category = transaction.category
            categoryTotals[category, default: 0] += abs(transaction.amount)
        }
        
        // Calcola le percentuali
        let percentages = categoryTotals.map { (category, amount) in
            CategoryPercentage(
                category: category,
                amount: amount,
                percentage: amount / totalExpense
            )
        }.sorted { $0.amount > $1.amount } // Ordina per importo decrescente
        
        return percentages
    }
    
    // Calcola le percentuali delle categorie di entrata
    private var incomeCategoryPercentages: [CategoryPercentage] {
        if totalIncome == 0 { return [] }
        
        // Raggruppa le entrate per categoria
        var categoryTotals: [String: Double] = [:]
        for transaction in transactions where transaction.amount > 0 {
            let category = transaction.category
            categoryTotals[category, default: 0] += transaction.amount
        }
        
        // Calcola le percentuali
        let percentages = categoryTotals.map { (category, amount) in
            CategoryPercentage(
                category: category,
                amount: amount,
                percentage: amount / totalIncome
            )
        }.sorted { $0.amount > $1.amount } // Ordina per importo decrescente
        
        return percentages
    }
}

#if DEBUG
#Preview {
    MainView()
}
#endif