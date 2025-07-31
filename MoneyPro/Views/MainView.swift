import SwiftUI

struct MainView: View {
    @StateObject private var transactionManager = TransactionManager()
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var showingNewTransaction = false
    @State private var transactionToEdit: Transaction?
    @State private var showingSettings = false
    @State private var showingPeriodSheet = false
    @State private var showingExpenseView = false
    @State private var showingIncomeView = false
    @State private var selectedCategory: String? = nil
    @State private var futureCheckTimer: Timer?
    @State private var dragOffset: CGFloat = 0
    @State private var showTotalInHeader: Bool = false
    @State private var showDivider: Bool = false
    @State private var scrollPosition: CGFloat = 0
    
    // Wave animation states
    @State private var waveScale: [CGFloat] = [2.0]
    @State private var waveOpacity: [Double] = [0.7]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { 
                MainHeader(
                    selectedPeriod: settingsManager.selectedPeriod,
                    monthOffset: settingsManager.currentMonthOffset,
                    showWaveAnimation: transactionManager.transactions.isEmpty,
                    waveScale: waveScale,
                    waveOpacity: waveOpacity,
                    netTotal: showTotalInHeader ? netTotal : nil,
                    showTotalInHeader: showTotalInHeader,
                    showDivider: showDivider,
                    onSettingsTap: { showingSettings = true },
                    onPeriodTap: { showingPeriodSheet = true },
                    onAddTransactionTap: { openNewTransaction() }
                )
                
                MainScrollContent(
                    periodDescription: settingsManager.selectedPeriod.periodDescription(withMonthOffset: settingsManager.currentMonthOffset),
                    netTotal: netTotal,
                    dragOffset: dragOffset,
                    filteredTransactions: filteredTransactions,
                    selectedCategory: $selectedCategory,
                    isEmpty: transactionManager.transactions.isEmpty,
                    upcomingTransactions: upcomingTransactions,
                    groupedTransactions: groupedTransactions,
                    expenses: expenses,
                    income: income,

                    onDragChanged: handleDragChanged,
                    onDragEnded: handleDragEnded,
                    onTransactionTap: openEditTransaction,
                    onScrollOffsetChanged: { offset in
                        // Debug print
                        // L'offset è la posizione del totale rispetto alla viewport
                        // Quando il totale esce dallo schermo di 200 punti, mostra il totale nell'header
                        let thresholdShow: CGFloat = -260  // Soglia per far apparire il totale nell'header
                        let thresholdHide: CGFloat = -260   // Soglia per far scomparire il totale dall'header
                        
                        // Gestione del divider con soglie -2/-1
                        let dividerThresholdShow: CGFloat = -1
                        let dividerThresholdHide: CGFloat = -1
                        
                        if offset < thresholdShow {
                             // Debug print
                            // Il totale è uscito dallo schermo: mostra il totale nell'header
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showTotalInHeader = true
                            }
                        } else if offset > thresholdHide {
                            // Debug print
                            // Il totale è tornato visibile: nascondi il totale dall'header
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showTotalInHeader = false
                            }
                        }
                        
                        // Gestione separata del divider
                        if offset < dividerThresholdShow {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showDivider = true
                            }
                        } else if offset > dividerThresholdHide {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                showDivider = false
                            }
                        }
                        // Se è tra le due soglie, mantieni lo stato attuale
                    },
                    onExpenseTap: handleExpenseTap,
                    onIncomeTap: handleIncomeTap
                )
                
            }
            .background(Colors.primaryBackground)
            .navigationBarHidden(true)
            .setupSheets(
                showingNewTransaction: $showingNewTransaction,
                showingSettings: $showingSettings,
                showingPeriodSheet: $showingPeriodSheet,
                showingExpenseView: $showingExpenseView,
                showingIncomeView: $showingIncomeView,
                showingWelcome: $settingsManager.showingWelcome,
                transactionToEdit: transactionToEdit,
                selectedPeriod: $settingsManager.selectedPeriod,
                onTransactionSave: handleTransactionSave,
                onTransactionDelete: handleTransactionDelete,
                onPeriodSelected: handlePeriodSelected,
                onWelcomeDismissed: { settingsManager.markWelcomeAsSeen() }
            )
            .setupLifecycle(
                transactionManager: transactionManager,
                settingsManager: settingsManager,
                onAppear: handleAppear,
                onDisappear: handleDisappear
            )
        }
    }
    
    // MARK: - Computed Properties
    private var filteredTransactions: [Transaction] {
        transactionManager.getTransactions(
            for: settingsManager.selectedPeriod,
            monthOffset: settingsManager.currentMonthOffset
        )
    }
    
    private var netTotal: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private var upcomingTransactions: [Transaction] {
        transactionManager.getUpcomingTransactions()
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        transactionManager.getGroupedTransactions()
    }
    
    private var expenses: Double {
        transactionManager.getExpenses(
            for: settingsManager.selectedPeriod,
            monthOffset: settingsManager.currentMonthOffset
        )
    }
    
    private var income: Double {
        transactionManager.getIncome(
            for: settingsManager.selectedPeriod,
            monthOffset: settingsManager.currentMonthOffset
        )
    }
    

    
    // MARK: - Action Handlers
    private func openNewTransaction() {
        transactionToEdit = nil
                                                showingNewTransaction = true
                                            }
    
    private func openEditTransaction(_ transaction: Transaction) {
        transactionToEdit = transaction
                                            showingNewTransaction = true
                                        }
    
    private func handleDragChanged(_ translation: CGFloat) {
        dragOffset = translation
    }
    
    private func handleDragEnded(_ translation: CGFloat) {
        let threshold: CGFloat = 80
        
        if translation > threshold {
            settingsManager.updateMonthOffset(settingsManager.currentMonthOffset - 1)
        } else if translation < -threshold {
            settingsManager.updateMonthOffset(settingsManager.currentMonthOffset + 1)
        }
        
        dragOffset = 0
    }
    
    private func handleTransactionSave(_ transaction: Transaction) {
                    if let editingTransaction = transactionToEdit {
            transactionManager.updateTransaction(transaction)
                    } else {
            transactionManager.addTransaction(transaction)
                    }
                    transactionToEdit = nil
                    showingNewTransaction = false
    }
    
        private func handleTransactionDelete() {
        if let transaction = transactionToEdit {
            transactionManager.deleteTransaction(transaction)
        }
        transactionToEdit = nil
        showingNewTransaction = false
    }
    
    private func handlePeriodSelected() {
        // Salva il periodo selezionato
        settingsManager.updatePeriod(settingsManager.selectedPeriod)
        settingsManager.resetToCurrentMonth()
    }
    
    private func handleExpenseTap() {
        showingExpenseView = true
    }
    
    private func handleIncomeTap() {
        showingIncomeView = true
    }
    
    private func handleAppear() {
        if transactionManager.transactions.isEmpty {
                    startWaveAnimation()
                }
                startFutureTransactionCheck()
            }
    
    private func handleDisappear() {
                stopFutureTransactionCheck()
    }
    
    // MARK: - Wave Animation
    private func startWaveAnimation() {
        withAnimation(
            Animation.easeOut(duration: 2.5)
                .repeatForever(autoreverses: false)
        ) {
            waveScale[0] = 2.5
            waveOpacity[0] = 0.0
        }
    }
    
    // MARK: - Future Transaction Management
    private func startFutureTransactionCheck() {
        transactionManager.processFutureTransactions()
        
        futureCheckTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            transactionManager.processFutureTransactions()
        }
    }
    
    private func stopFutureTransactionCheck() {
        futureCheckTimer?.invalidate()
        futureCheckTimer = nil
    }
}

// MARK: - View Extensions
extension View {
    func setupSheets(
        showingNewTransaction: Binding<Bool>,
        showingSettings: Binding<Bool>,
        showingPeriodSheet: Binding<Bool>,
        showingExpenseView: Binding<Bool>,
        showingIncomeView: Binding<Bool>,
        showingWelcome: Binding<Bool>,
        transactionToEdit: Transaction?,
        selectedPeriod: Binding<Period>,
        onTransactionSave: @escaping (Transaction) -> Void,
        onTransactionDelete: @escaping () -> Void,
        onPeriodSelected: @escaping () -> Void,
        onWelcomeDismissed: @escaping () -> Void
    ) -> some View {
        self
            .sheet(isPresented: showingNewTransaction) {
                NewTransactionView(transactionToEdit: transactionToEdit) { transaction in
                    onTransactionSave(transaction)
                } onDelete: {
                    onTransactionDelete()
                }
                .presentationDetents([.fraction(0.92)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(.clear)
            }
            .sheet(isPresented: showingSettings) {
                SettingView(isPresented: showingSettings) {
                    showingSettings.wrappedValue = false
                }
                .presentationDetents([.fraction(0.92)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(.clear)
            }
            .sheet(isPresented: showingPeriodSheet) {
                PeriodSelectionSheet(
                    selectedPeriod: selectedPeriod,
                    isPresented: showingPeriodSheet
                ) {
                    onPeriodSelected()
                }
            }
            .sheet(isPresented: showingExpenseView) {
                ExpenseView(isPresented: showingExpenseView)
                    .presentationDetents([.fraction(0.92)])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.clear)
            }
            .sheet(isPresented: showingIncomeView) {
                IncomeView(isPresented: showingIncomeView)
                    .presentationDetents([.fraction(0.92)])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.clear)
            }
            .fullScreenCover(isPresented: showingWelcome) {
                WelcomeView(isPresented: showingWelcome) {
                    onWelcomeDismissed()
                }
            }
    }
    
    func setupLifecycle(
        transactionManager: TransactionManager,
        settingsManager: SettingsManager,
        onAppear: @escaping () -> Void,
        onDisappear: @escaping () -> Void
    ) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                transactionManager.processFutureTransactions()
                settingsManager.resetToCurrentMonth()
            }
            .onReceive(NotificationCenter.default.publisher(for: .categoriesDidChange)) { _ in
                transactionManager.objectWillChange.send()
            }
            .onAppear {
                onAppear()
            }
            .onDisappear {
                onDisappear()
            }
            .onChange(of: transactionManager.transactions.isEmpty) { _, isEmpty in
                if isEmpty {
                    // Start wave animation when transactions become empty
                }
            }
    }
}

#if DEBUG
#Preview {
    MainView()
}
#endif
