// MARK: - Import
import SwiftUI
import UIKit

// MARK: - Notifiche
extension Notification.Name {
    static let categoriesDidChange = Notification.Name("categoriesDidChange")
}



// MARK: - View Principale Nuova Transazione
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Aggiungo un nuovo modifier per gestire la tastiera
struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    keyboardHeight = keyboardFrame.height
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
    }
}

struct NewTransactionView: View {
    // MARK: - State e Variabili
    @Environment(\.dismiss) private var dismiss
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var description = ""
    @State private var amount = ""
    @State private var category = ""
    @State private var date = Date()
    @State private var isExpense = true
    @State private var currentPage: Int = 1 // 0 = categorie, 1 = tastierino, 2 = calendario
    @State private var shakeAmount: Double = 0
    @State private var categoryShake: Double = 0
    @State private var descriptionShake: Double = 0
    @State private var shouldNavigateToCategoryView = false
    @State private var navigationPath: [String] = []
    @State private var categoryToEdit: CategoryItem? = nil
    let transactionToEdit: Transaction?
    let onSave: (Transaction) -> Void
    let onDelete: (() -> Void)?
    
    init(transactionToEdit: Transaction? = nil, onSave: @escaping (Transaction) -> Void, onDelete: (() -> Void)? = nil) {
        self.transactionToEdit = transactionToEdit
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    // MARK: - Categorie
    private var expenseCategories: [CategoryItem] {
        [
            CategoryItem(name: "Cibo", color: Colors.categoriaCibo, emoji: "🍖"),
            CategoryItem(name: "Macchina", color: Colors.categoriaMacchina, emoji: "🚙"),
            CategoryItem(name: "Svago", color: Colors.categoriaSvago, emoji: "🍿"),
            CategoryItem(name: "Casa", color: Colors.categoriaCasa, emoji: "🏡"),
            CategoryItem(name: "Shopping", color: Colors.categoriaShopping, emoji: "🛍️"),
            CategoryItem(name: "Salute", color: Colors.categoriaSalute, emoji: "🫀"),
        ]
    }
    private var incomeCategories: [CategoryItem] {
        [
            CategoryItem(name: "Stipendio", color: Colors.categoriaStipendio, emoji: "💼"),
            CategoryItem(name: "Regalo", color: Colors.categoriaRegalo, emoji: "🎁"),
            CategoryItem(name: "Bonus", color: Colors.categoriaBonus, emoji: "💸"),
        ]
    }
    
    // MARK: - Categorie Dinamiche
    @State private var customExpenseCategories: [CategoryItem] = []
    @State private var customIncomeCategories: [CategoryItem] = []
    
    private var allExpenseCategories: [CategoryItem] {
        expenseCategories + customExpenseCategories
    }
    
    private var allIncomeCategories: [CategoryItem] {
        incomeCategories + customIncomeCategories
    }
    
    // MARK: - Caricamento Categorie
    private func loadCategories() {
        customExpenseCategories = coreDataManager.loadCategories(isExpense: true)
        customIncomeCategories = coreDataManager.loadCategories(isExpense: false)
    }
    
    // MARK: - Persistenza Categorie
    private func saveCategories() {
        // Le categorie vengono salvate automaticamente da Core Data
        // Questa funzione è mantenuta per compatibilità
    }
    

    

    
    // MARK: - Salvataggio Categoria
    private func saveNewCategory(_ category: CategoryItem) {
        coreDataManager.saveCategory(category, isExpense: isExpense)
        loadCategories() // Ricarica le categorie
        
        // Notifica il cambiamento delle categorie
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
    }
    
    // MARK: - Modifica Categoria
    private func updateCategory(_ updatedCategory: CategoryItem) {
        if let editingCategory = categoryToEdit {
            // Elimina la categoria vecchia e salva quella nuova
            coreDataManager.deleteCategory(editingCategory)
            coreDataManager.saveCategory(updatedCategory, isExpense: isExpense)
            loadCategories() // Ricarica le categorie
            
            // Aggiorna le transazioni che usano questa categoria
            updateTransactionsForCategory(oldName: editingCategory.name, newName: updatedCategory.name)
            
            // Notifica il cambiamento delle categorie
            NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
        }
        categoryToEdit = nil
    }
    
       // MARK: - Eliminazione Categoria
    private func deleteCategory(_ category: CategoryItem) {
        coreDataManager.deleteCategory(category)
        loadCategories() // Ricarica le categorie
        
        // Elimina le transazioni che usano questa categoria
        deleteTransactionsForCategory(categoryName: category.name)
        
        // Notifica il cambiamento delle categorie
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
    }
    
    // MARK: - Gestione Transazioni
    private func updateTransactionsForCategory(oldName: String, newName: String) {
        // Carica le transazioni esistenti
        var transactions = coreDataManager.loadTransactions()

        // Aggiorna le transazioni che usano la vecchia categoria
        for i in 0..<transactions.count {
            if transactions[i].category.lowercased() == oldName.lowercased() {
                let updatedTransaction = Transaction(
                    id: transactions[i].id,
                    description: transactions[i].description,
                    amount: transactions[i].amount,
                    category: newName,
                    date: transactions[i].date
                )
                coreDataManager.updateTransaction(updatedTransaction)
            }
        }
    }

    private func deleteTransactionsForCategory(categoryName: String) {
        // Carica le transazioni esistenti
        let transactions = coreDataManager.loadTransactions()

        // Rimuovi le transazioni che usano questa categoria
        for transaction in transactions {
            if transaction.category.lowercased() == categoryName.lowercased() {
                coreDataManager.deleteTransaction(transaction)
            }
        }
    }

    private func loadTransactions() -> [Transaction] {
        return coreDataManager.loadTransactions()
    }

    private func saveTransactions(_ transactions: [Transaction]) {
        // Questa funzione è ora gestita da Core Data
        // Mantenuta per compatibilità
    }
    
    // MARK: - Corpo della View
    var body: some View {
        ZStack {
            // Contenuto principale
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer().frame(height: 10) // Spazio superiore
                    headerView // Header con chiusura e toggle
                    VStack(spacing: 0) {
                        // Importo centrato verticalmente
                VStack(spacing: 0) {
                    Spacer()
                    amountView
                    Spacer()
                }
                .allowsHitTesting(true)
                    }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                    // Blocco sempre visibile con 3 bottoni + contenuto variabile
                    VStack(spacing: 0) {
                        // I 3 bottoni (sempre visibili)
                VStack(spacing: 12) {
                    descriptionView
                    dateCategoryButtons
                }
                        // Contenuto variabile in base alla pagina
                        slidingPanelView()
                            .frame(height: 340)
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, -10) // Sposta verso il basso di 10 punti
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Colors.primaryBackground)
            .allowsHitTesting(true)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
            .modifier(KeyboardAwareModifier())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
                hideKeyboard()
            }
           .onAppear {
               loadCategories() // Carica le categorie salvate all'apertura
               
               // Se stiamo modificando una transazione, popola i campi
               if let editingTransaction = transactionToEdit {
                   description = editingTransaction.description
                   amount = String(abs(editingTransaction.amount))
                   category = editingTransaction.category
                   date = editingTransaction.date
                   isExpense = editingTransaction.amount < 0
               } else {
                   // Imposta le categorie di default per nuova transazione
                   if isExpense {
                       category = "Cibo"
                   } else {
                       category = "Stipendio"
                   }
               }
           }
            
                            // CategoryView con animazione dal basso
                if shouldNavigateToCategoryView {
                    CategoryView(
                        isExpense: isExpense,
                        existingCategory: categoryToEdit
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            shouldNavigateToCategoryView = false
                            categoryToEdit = nil
                        }
                    } onSaveCategory: { newCategory in
                        if categoryToEdit != nil {
                            updateCategory(newCategory)
                        } else {
                            saveNewCategory(newCategory)
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            shouldNavigateToCategoryView = false
                            categoryToEdit = nil
                        }
                    } onDeleteCategory: { categoryToDelete in
                        deleteCategory(categoryToDelete)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            shouldNavigateToCategoryView = false
                            categoryToEdit = nil
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: shouldNavigateToCategoryView)
                    .zIndex(1)
                }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
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
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            
            // Pulsante cestino per eliminare (solo quando si modifica una transazione)
            if let transactionToEdit = transactionToEdit {
                Button(action: {
                    // Vibrazione di conferma per l'eliminazione
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onDelete?()
                }) {
                    Image("ic_trash")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Colors.errorText)
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
            }
            
            Spacer()
            // Toggle Spesa/Entrata
            HStack(spacing: 0) {
                ZStack(alignment: isExpense ? .leading : .trailing) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Colors.secondaryBackground)
                        .frame(width: 80, height: 44)
                        .animation(.easeInOut(duration: 0.25), value: isExpense)
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation { isExpense = true }
                            category = "Cibo"
                        }) {
                            Text("Spesa")
                                .font(AppFonts.buttonText)
                                .fontWeight(.semibold)
                                .foregroundColor(isExpense ? Colors.primaryColor : Colors.secondaryText)
                                .frame(width: 80, height: 44)
                                .background(isExpense ? Colors.secondaryBackground : Color.clear)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            withAnimation { isExpense = false }
                            category = "Stipendio"
                        }) {
                            Text("Entrata")
                                .font(AppFonts.buttonText)
                                .fontWeight(.semibold)
                                .foregroundColor(!isExpense ? Colors.primaryColor : Colors.secondaryText)
                                .frame(width: 80, height: 44)
                                .background(!isExpense ? Colors.secondaryBackground : Color.clear)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Colors.primaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Colors.outlineColor, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .allowsHitTesting(true)
        .onAppear {
            // Forza il refresh della view quando appare
            print("NewTransactionView appeared, transactionToEdit: \(transactionToEdit != nil)")
            if transactionToEdit != nil {
                // La view si aggiornerà automaticamente
            }
        }
    }

    // MARK: - Amount View
    private var amountView: some View {
        VStack(spacing: 20) {
            ZStack {
                HStack { Spacer() }
                HStack(spacing: 6) {
                    Text(amount.isEmpty ? "0" : amount)
                        .font(AppFonts.amountDisplay)
                        .fontWeight(.medium)
                        .foregroundColor(Colors.primaryText)
                        .modifier(ShakeEffect(animatableData: shakeAmount))
                    Text("€")
                        .font(AppFonts.amountSymbol)
                        .fontWeight(.light)
                        .foregroundColor(Colors.secondaryText)
                        .modifier(ShakeEffect(animatableData: shakeAmount))
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .offset(x: 16)
                if !amount.isEmpty {
                    HStack {
                        Spacer()
                        Button(action: { amount.removeLast() }) {
                            Image(systemName: "arrow.backward.circle.fill")
                                .font(.title2)
                                .foregroundColor(Colors.secondaryText)
                        }
                        .padding(.trailing, 20)
                    }
                }
            }
        }
    }

    // MARK: - Descrizione
    private var descriptionView: some View {
        ZStack {
            if description.isEmpty {
                Text("Aggiungi Descrizione")
                    .font(AppFonts.buttonText)
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.secondaryText)
                    .modifier(ShakeEffect(animatableData: descriptionShake))
            }
            TextField("", text: $description)
                .font(AppFonts.buttonText)
                .fontWeight(.semibold)
                .foregroundColor(Colors.primaryText)
                .multilineTextAlignment(.center)
                .textFieldStyle(PlainTextFieldStyle())
                .tint(Colors.primaryColor)
                .modifier(ShakeEffect(animatableData: descriptionShake))
                .submitLabel(.done)
                .autocorrectionDisabled(false)
                .textInputAutocapitalization(.sentences)
                .keyboardType(.default)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Colors.primaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Colors.outlineColor, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Bottoni Categoria/Data
    private var dateCategoryButtons: some View {
        HStack(spacing: 12) {
            // Bottone Categoria
            if currentPage == 0 {
                Button(action: { goToPage(1) }) {
                    HStack {
                        Spacer()
                        Text("Chiudi")
                            .font(AppFonts.buttonText)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.errorText)
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(Colors.error)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Colors.errorText.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: { goToPage(0) }) {
                    let currentCategories = isExpense ? allExpenseCategories : allIncomeCategories
                    let selectedCategory = currentCategories.first(where: { $0.name == category })
                    HStack(spacing: 6) {
                        if let selectedCategory = selectedCategory {
                            Text(selectedCategory.emoji)
                                .modifier(ShakeEffect(animatableData: categoryShake))
                        }
                        Text(category.isEmpty ? "Categoria" : category)
                            .font(AppFonts.buttonText)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedCategory != nil ? Colors.primaryColor : Colors.secondaryText)
                            .modifier(ShakeEffect(animatableData: categoryShake))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(selectedCategory?.color.opacity(0.15) ?? Colors.primaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Colors.outlineColor, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            // Bottone Data
            if currentPage == 2 {
                Button(action: { goToPage(1) }) {
                    HStack {
                        Spacer()
                        Text("Chiudi")
                            .font(AppFonts.buttonText)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.errorText)
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(Colors.error)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Colors.errorText.opacity(0.1), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: { goToPage(2) }) {
                    HStack {
                        Spacer()
                        Text(dateFormatter.string(from: date))
                            .font(AppFonts.buttonText)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.primaryText)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Colors.primaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Colors.outlineColor, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Sliding Panel (Categorie, Tastierino, Calendario)
    private func slidingPanelView() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            HStack(spacing: 0) {
                // Categorie (pagina 0)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach((isExpense ? allExpenseCategories : allIncomeCategories)) { cat in
                            ZStack {
                                    HStack {
                                        Text(cat.emoji)
                                        Text(cat.name)
                                            .font(AppFonts.buttonText)
                                            .fontWeight(.semibold)
                                            .foregroundColor(category == cat.name ? Colors.primaryColor : Colors.primaryText)
                                    }
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background((category == cat.name ? cat.color.opacity(1) : cat.color.opacity(0.15)))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Colors.outlineColor, lineWidth: 1)
                                    )
                                }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                category = cat.name
                                goToPage(1)
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                // Solo le categorie personalizzate possono essere modificate
                                if customExpenseCategories.contains(where: { $0.id == cat.id }) || 
                                   customIncomeCategories.contains(where: { $0.id == cat.id }) {
                                    categoryToEdit = cat
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        shouldNavigateToCategoryView = true
                                    }
                                }
                            }

                           .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                               // Solo le categorie personalizzate possono essere eliminate
                               if customExpenseCategories.contains(where: { $0.id == cat.id }) ||
                                  customIncomeCategories.contains(where: { $0.id == cat.id }) {
                                   Button(role: .destructive) {
                                       deleteCategory(cat)
                                   } label: {
                                       Label("Elimina", systemImage: "ic_trash")
                                   }
                               }
                           }
                        }
                        
                        // Tasto Aggiungi
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                shouldNavigateToCategoryView = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Colors.secondaryText)
                                Text("Aggiungi")
                                    .font(AppFonts.buttonText)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Colors.secondaryText)
                        }
                        .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Colors.primaryBackground)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Colors.outlineColor, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                        .transaction { $0.animation = nil }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                .frame(width: width)
                .ignoresSafeArea(.container, edges: .bottom)
                // Tastierino (pagina 1)
                VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            ForEach(1...3, id: \.self) { number in
                                NumberButton(number: "\(number)", action: { appendNumber("\(number)") })
                            }
                        }
                    .padding(.bottom, 12)
                        HStack(spacing: 12) {
                            ForEach(4...6, id: \.self) { number in
                                NumberButton(number: "\(number)", action: { appendNumber("\(number)") })
                            }
                        }
                    .padding(.bottom, 12)
                        HStack(spacing: 12) {
                            ForEach(7...9, id: \.self) { number in
                                NumberButton(number: "\(number)", action: { appendNumber("\(number)") })
                            }
                        }
                    .padding(.bottom, 12)
                        HStack(spacing: 12) {
                            NumberButton(number: ".", action: { appendNumber(".") })
                            NumberButton(number: "0", action: { appendNumber("0") })
                            ConfirmButton(action: saveTransaction)
                        }
                    }
                    .padding(.horizontal, 20)
                .padding(.top, 0)
                .frame(width: width)
                .ignoresSafeArea(.container, edges: .bottom)
                // Calendario (pagina 2)
                VStack {
                    Spacer()
                    HStack {
                        Spacer(minLength: 0)
                        DatePicker("Data", selection: $date, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .colorScheme(.light)
                        Spacer(minLength: 0)
                    }
                }
                .frame(width: width, height: 250)
                .background(Colors.primaryBackground)
            }
            .frame(width: width * 3, alignment: .leading)
            .offset(x: -CGFloat(currentPage) * width)
            .animation(.easeInOut(duration: 0.35), value: currentPage)
        }
        // rimosso frame height per permettere allo slider di andare a fondo
        .allowsHitTesting(true)
        .clipped()
    }

    // MARK: - Funzioni di Utilità
    private func appendNumber(_ number: String) {
        if number == "." && amount.contains(".") { return }
        let newAmount: String
        if amount == "0" && number != "." { newAmount = number }
        else { newAmount = amount + number }
        let components = newAmount.split(separator: ".", omittingEmptySubsequences: false)
        let integerPart = components.first ?? ""
        let decimalPart = components.count > 1 ? components[1] : ""
        if integerPart.count > 5 || decimalPart.count > 2 {
            shakeAmount = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.default) {
                    shakeAmount = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shakeAmount = 0
                }
            }
            return
        }
        amount = newAmount
    }
    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            if amount.isEmpty {
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
                shakeAmount = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.default) {
                        shakeAmount = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        shakeAmount = 0
                    }
                }
                return
            }
            return
        }
        if amountValue == 0 {
            DispatchQueue.main.async {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            shakeAmount = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.default) {
                    shakeAmount = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shakeAmount = 0
                }
            }
            return
        }
        if category.isEmpty {
            DispatchQueue.main.async {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            categoryShake = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.default) {
                    categoryShake = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    categoryShake = 0
                }
            }
            return
        }
        let finalAmount = isExpense ? -amountValue : amountValue
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        let transaction = Transaction(
            id: transactionToEdit?.id ?? UUID(),
            description: description,
            amount: finalAmount,
            category: category,
            date: date
        )
        onSave(transaction)
        dismiss()
    }
    private func goToPage(_ page: Int) {
        withAnimation(.easeInOut(duration: 0.35)) {
            currentPage = page
        }
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter
    }
}

// MARK: - Componenti Riutilizzabili
struct NumberButton: View {
    let number: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(AppFonts.numberPad)
                .fontWeight(.medium)
                .foregroundColor(Colors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Colors.secondaryBackground)
                .cornerRadius(12)
        }
    }
}

struct ConfirmButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(AppFonts.numberPad.weight(.bold))
                .fontWeight(.bold)
                .foregroundColor(Colors.primaryBackground)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Colors.primaryColor)
                .cornerRadius(12)
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: Double
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 3 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#if DEBUG
#Preview {
    NewTransactionView { transaction in
        print("Nuova transazione: \(transaction)")
    }
}
#endif

// FINE FILE

