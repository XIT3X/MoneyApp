// MARK: - Import
import SwiftUI
import UIKit





// MARK: - View Principale Nuova Transazione

struct NewTransactionView: View {
    // MARK: - State e Variabili
    @Environment(\.dismiss) private var dismiss
    
    @State private var description = ""
    @State private var amount = ""
    @State private var category = ""
    @State private var date = Date()
    @State private var isExpense = true
    @State private var currentPage: Int = 1 // 0 = categorie, 1 = tastierino, 2 = calendario
    @State private var shakeAmount: Double = 0
    @State private var categoryShake: Double = 0
    @State private var descriptionShake: Double = 0
    @State private var showingCategoryView = false
    @State private var editingCategory: CategoryItem? = nil
    @State private var customExpenseCategories: [CategoryItem] = []
    @State private var customIncomeCategories: [CategoryItem] = []
    @State private var categoriesAnimationTrigger = false
    
    let transactionToEdit: Transaction?
    let onSave: (Transaction) -> Void
    let onDelete: (() -> Void)?
    
    init(transactionToEdit: Transaction? = nil, onSave: @escaping (Transaction) -> Void, onDelete: (() -> Void)? = nil) {
        self.transactionToEdit = transactionToEdit
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    // MARK: - Categorie
    private var allExpenseCategories: [CategoryItem] {
        var categories = [
            CategoryItem(name: "Cibo", color: Colors.categoriaCibo, emoji: "🍖"),
            CategoryItem(name: "Macchina", color: Colors.categoriaMacchina, emoji: "🚙"),
            CategoryItem(name: "Svago", color: Colors.categoriaSvago, emoji: "🍿"),
            CategoryItem(name: "Casa", color: Colors.categoriaCasa, emoji: "🏡"),
            CategoryItem(name: "Shopping", color: Colors.categoriaShopping, emoji: "🛍️"),
            CategoryItem(name: "Salute", color: Colors.categoriaSalute, emoji: "🫀"),
            CategoryItem(name: "Trasporti", color: Colors.categoriaTrasporti, emoji: "🚌"),
            CategoryItem(name: "Sport", color: Colors.categoriaSport, emoji: "⚽"),
            CategoryItem(name: "Viaggi", color: Colors.categoriaViaggi, emoji: "✈️"),
            CategoryItem(name: "Animali", color: Colors.categoriaAnimali, emoji: "🐕"),
            CategoryItem(name: "Spesa", color: Colors.categoriaSpesa, emoji: "🛒"),
            CategoryItem(name: "Regali", color: Colors.categoriaRegali, emoji: "🎁")
        ]
        categories.append(contentsOf: customExpenseCategories)
        return categories
    }
    
    private var allIncomeCategories: [CategoryItem] {
        var categories = [
            CategoryItem(name: "Stipendio", color: Colors.categoriaStipendio, emoji: "💼"),
            CategoryItem(name: "Regalo", color: Colors.categoriaRegalo, emoji: "🎁"),
            CategoryItem(name: "Bonus", color: Colors.categoriaBonus, emoji: "💸"),
            CategoryItem(name: "Investimenti", color: Colors.categoriaInvestimenti, emoji: "📈")
        ]
        categories.append(contentsOf: customIncomeCategories)
        return categories
    }
    
    
    
    
    // MARK: - Corpo della View
    var body: some View {
        ZStack {
            // Contenuto principale
            GeometryReader { geometry in
                VStack(spacing: 0) {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.bottom, -10) // Sposta verso il basso di 10 punti
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Colors.primaryBackground)
                .allowsHitTesting(true)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .overlay(
                // CategoryView overlay
                Group {
                    if showingCategoryView {
                        CategoryView(
                            isExpense: isExpense,
                            existingCategory: editingCategory,
                            onDismiss: {
                                showingCategoryView = false
                                editingCategory = nil
                            },
                            onSaveCategory: { updatedCategory in
                                if let editing = editingCategory {
                                    // Modifica categoria esistente
                                    if isExpense {
                                        if let index = customExpenseCategories.firstIndex(where: { $0.id == editing.id }) {
                                            customExpenseCategories[index] = updatedCategory
                                        }
                                    } else {
                                        if let index = customIncomeCategories.firstIndex(where: { $0.id == editing.id }) {
                                            customIncomeCategories[index] = updatedCategory
                                        }
                                    }
                                } else {
                                    // Aggiungi nuova categoria
                                    if isExpense {
                                        customExpenseCategories.append(updatedCategory)
                                    } else {
                                        customIncomeCategories.append(updatedCategory)
                                    }
                                }
                                // Salva le categorie personalizzate
                                saveCustomCategories()
                                showingCategoryView = false
                                editingCategory = nil
                            },
                            onDeleteCategory: { categoryToDelete in
                                // Rimuovi la categoria dalla lista appropriata
                                if isExpense {
                                    customExpenseCategories.removeAll { $0.id == categoryToDelete.id }
                                } else {
                                    customIncomeCategories.removeAll { $0.id == categoryToDelete.id }
                                }
                                // Salva le categorie personalizzate
                                saveCustomCategories()
                                showingCategoryView = false
                                editingCategory = nil
                            }
                        )
                        .transition(.opacity)
                    }
                }
            )
            .modifier(KeyboardAwareModifier())
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                // Carica le categorie personalizzate immediatamente
                loadCustomCategories()
                
                // Attiva l'animazione delle categorie
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        categoriesAnimationTrigger = true
                    }
                }
                
                // Inizializza i dati se si sta modificando una transazione
                if let transaction = transactionToEdit {
                    description = transaction.description
                    amount = String(format: "%.2f", abs(transaction.amount))
                    category = transaction.category
                    date = transaction.date
                    isExpense = transaction.amount < 0
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Colors.primaryColor.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(Colors.primaryBackground)
                    .cornerRadius(12)
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
                        .frame(width: 24, height: 24)
                        .foregroundColor(Colors.errorText.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Colors.errorText.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
            
            Spacer()
            // Toggle Spesa/Entrata
            HStack(spacing: 0) {
                ZStack(alignment: isExpense ? .leading : .trailing) {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Colors.secondaryBackground)
                        .frame(width: 80, height: 44)
                        .animation(.easeInOut(duration: 0.25), value: isExpense)
                    HStack(spacing: 0) {
                        Button(action: {
                            isExpense = true
                            category = "Cibo"
                        }) {
                            Text("Spesa")
                                .font(AppFonts.buttonText)
                                .fontWeight(.semibold)
                                .foregroundColor(isExpense ? Colors.primaryColor : Colors.secondaryText)
                                .frame(width: 80, height: 44)
                                .background(isExpense ? Colors.secondaryBackground : Color.clear)
                                .cornerRadius(22)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action: {
                            isExpense = false
                            category = "Stipendio"
                        }) {
                            Text("Entrata")
                                .font(AppFonts.buttonText)
                                .fontWeight(.semibold)
                                .foregroundColor(!isExpense ? Colors.primaryColor : Colors.secondaryText)
                                .frame(width: 80, height: 44)
                                .background(!isExpense ? Colors.secondaryBackground : Color.clear)
                                .cornerRadius(22)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Colors.primaryBackground)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Colors.outlineColor, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .allowsHitTesting(true)
        .onAppear {
            // Forza il refresh della view quando appare
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
                        }
                        Text(category.isEmpty ? "Categoria" : category)
                            .font(AppFonts.buttonText)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedCategory != nil ? Colors.primaryColor : Colors.secondaryText)
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
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach((isExpense ? allExpenseCategories : allIncomeCategories), id: \.id) { cat in
                        VStack(spacing: 4) {
                            Text(cat.emoji)
                                .font(.system(size: 22))
                            Text(cat.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(category == cat.name ? Colors.primaryColor : Colors.primaryText)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background((category == cat.name ? cat.color.opacity(1) : cat.color.opacity(0.15)))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Colors.outlineColor, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            category = cat.name
                            goToPage(1)
                        }
                        .onLongPressGesture {
                            editingCategory = cat
                            showingCategoryView = true
                        }
                        .offset(x: categoriesAnimationTrigger ? 0 : -100)
                        .animation(.easeInOut(duration: 0.35).delay(Double(allExpenseCategories.firstIndex(where: { $0.id == cat.id }) ?? 0) * 0.05), value: categoriesAnimationTrigger)
                        
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .frame(width: width)
                .id("categories-\(isExpense ? "expense" : "income")-\(customExpenseCategories.count + customIncomeCategories.count)")
                .animation(.easeInOut(duration: 0.3), value: customExpenseCategories.count + customIncomeCategories.count)
                .animation(.easeInOut(duration: 0.35), value: categoriesAnimationTrigger)
                
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
                .padding(.top, 12)
                .frame(width: width)
                
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
    }
    // rimosso frame height per permettere allo slider di andare a fondo
    
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
    

    
    // MARK: - Caricamento Categorie Personalizzate
    private func loadCustomCategories() {
        // Carica categorie spese personalizzate
        if let expenseData = UserDefaults.standard.array(forKey: "customExpenseCategories") as? [[String: Any]] {
            customExpenseCategories = expenseData.compactMap { data in
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
        }
        
        // Carica categorie entrate personalizzate
        if let incomeData = UserDefaults.standard.array(forKey: "customIncomeCategories") as? [[String: Any]] {
            customIncomeCategories = incomeData.compactMap { data in
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
        }
    }
    
    // Funzione helper per convertire hex in Color
    private func hexToColor(_ hex: String) -> Color {
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
    
    // Funzione helper per convertire Color in hex
    private func colorToHex(_ color: Color) -> String {
        // Map dei colori ai loro valori hex
        switch color {
        case Colors.categoriaCibo: return "#ffbeaa"
        case Colors.categoriaMacchina: return "#9acdf9"
        case Colors.categoriaSvago: return "#addab0"
        case Colors.categoriaCasa: return "#ffd08c"
        case Colors.categoriaShopping: return "#f499b7"
        case Colors.categoriaSalute: return "#f9aaa5"
        case Colors.categoriaStipendio: return "#c0b2ab"
        case Colors.categoriaRegalo: return "#cfbee7"
        case Colors.categoriaBonus: return "#d19eda"
        case Colors.categoriaBonus2: return "#9ed7da"
        case Colors.incoming: return "#00B4D8"
        default: return "#ffbeaa"
        }
    }
    

    
    // MARK: - Salvataggio Categorie Personalizzate
    private func saveCustomCategories() {
        // Salva categorie spese personalizzate
        let expenseData = customExpenseCategories.map { category in
            [
                "id": category.id.uuidString,
                "name": category.name,
                "colorHex": colorToHex(category.color),
                "emoji": category.emoji
            ]
        }
        UserDefaults.standard.set(expenseData, forKey: "customExpenseCategories")
        
        // Salva categorie entrate personalizzate
        let incomeData = customIncomeCategories.map { category in
            [
                "id": category.id.uuidString,
                "name": category.name,
                "colorHex": colorToHex(category.color),
                "emoji": category.emoji
            ]
        }
        UserDefaults.standard.set(incomeData, forKey: "customIncomeCategories")
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
    

    
#if DEBUG
    #Preview {
        NewTransactionView { transaction in
            // Preview transaction
        }
    }
#endif
    
    // FINE FILE
}
