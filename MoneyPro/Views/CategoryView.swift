// MARK: - Import
import SwiftUI
import UIKit

// MARK: - Category View
struct CategoryView: View {
    let isExpense: Bool
    let existingCategory: CategoryItem?
    @State private var selectedColor: Color = Colors.categoriaCibo
    @State private var newCategoryTitle: String = ""
    @State private var selectedEmoji: String = "🍖"
    @State private var isClosing = false
    @State private var titleShake: Double = 0
    @State private var colorShake: Double = 0
    @State private var emojiShake: Double = 0
    let onDismiss: () -> Void
    let onSaveCategory: (CategoryItem) -> Void
   let onDeleteCategory: ((CategoryItem) -> Void)?
    
    // MARK: - Vibrazioni
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    private func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    init(isExpense: Bool, existingCategory: CategoryItem? = nil, onDismiss: @escaping () -> Void, onSaveCategory: @escaping (CategoryItem) -> Void, onDeleteCategory: ((CategoryItem) -> Void)? = nil) {
        self.isExpense = isExpense
        self.existingCategory = existingCategory
        self.onDismiss = onDismiss
        self.onSaveCategory = onSaveCategory
        self.onDeleteCategory = onDeleteCategory
        
        // Pre-popola i campi se si tratta di una modifica
        if let category = existingCategory {
            self._newCategoryTitle = State(initialValue: category.name)
            self._selectedColor = State(initialValue: category.color)
            self._selectedEmoji = State(initialValue: category.emoji)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacing
                Spacer().frame(height: 10)
                
                // Header
                headerView
                
                // Content area
                VStack {
                    
                    
                    
                    // TextField per il titolo
                    ZStack {
                        if newCategoryTitle.isEmpty {
                            Text("Nome categoria")
                                .font(AppFonts.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Colors.secondaryText)
                                .modifier(ShakeEffect(animatableData: titleShake))
                        }
                        TextField("", text: $newCategoryTitle)
                            .font(AppFonts.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Colors.primaryText)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(PlainTextFieldStyle())
                            .tint(Colors.primaryColor)
                            .submitLabel(.done)
                            .autocorrectionDisabled(false)
                            .textInputAutocapitalization(.sentences)
                            .keyboardType(.default)
                            .modifier(ShakeEffect(animatableData: titleShake))
                                                                                                    .onChange(of: newCategoryTitle) { newValue in
                                        // Limita a 15 caratteri
                                        if newValue.count > 15 {
                                            newCategoryTitle = String(newValue.prefix(15))
                                            // Shake per indicare il limite raggiunto
                                            titleShake = 0
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                withAnimation(.default) {
                                                    titleShake = 1
                                                }
                                            }
                                        }
                                    }
                    }
                    
                    
                    
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Colors.primaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Colors.outlineColor, lineWidth: 1)
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    

                    
                    // Griglia emoji
                    emojiGrid
                        .padding(.top, 20)
                        .modifier(ShakeEffect(animatableData: emojiShake))
                        .padding(.horizontal, 20)
                    
                    
                    // Griglia colori
                    colorGrid
                        .padding(.top, 20)
                        .modifier(ShakeEffect(animatableData: colorShake))
                        .padding(.horizontal, 20)

                    
                    Spacer()
                    

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Colors.primaryBackground)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding(.horizontal, 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Colors.primaryBackground)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .modifier(KeyboardAwareModifier())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: isClosing) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
       .onAppear {
           // Vibrazione di apertura
           hapticFeedback(.light)
       }
    }
    
    // MARK: - Validazione
    private func validateFields() -> Bool {
        var isValid = true
        
        // Validazione titolo
        if newCategoryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleShake = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.default) {
                    titleShake = 1
                }
            }
           // Vibrazione di errore
           notificationFeedback(.error)
            isValid = false
        }
        
        return isValid
    }
    
            // MARK: - Salvataggio Categoria
    private func saveCategory() {
        let trimmedTitle = newCategoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se si tratta di una modifica, mantieni l'ID originale
        let categoryToSave: CategoryItem
        if let existing = existingCategory {
            categoryToSave = CategoryItem(
                id: existing.id,  // Mantieni l'ID originale
                name: trimmedTitle,
                color: selectedColor,
                emoji: selectedEmoji
            )
        } else {
            categoryToSave = CategoryItem(
                name: trimmedTitle,
                color: selectedColor,
                emoji: selectedEmoji
            )
        }
        
        // Vibrazione di successo
        notificationFeedback(.success)
        
        // Salva la categoria tramite callback
        onSaveCategory(categoryToSave)
        
        // Chiudi la view
        withAnimation(.easeInOut(duration: 0.3)) {
            isClosing = true
        }
    }
    
   // MARK: - Eliminazione Categoria
   private func deleteCategory() {
       guard let existing = existingCategory else { return }
       
       // Vibrazione di successo per eliminazione
       notificationFeedback(.success)
       
       // Elimina la categoria tramite callback
       onDeleteCategory?(existing)
       
       // Chiudi la view
       withAnimation(.easeInOut(duration: 0.3)) {
           isClosing = true
       }
   }
    
    // MARK: - Color Grid
    private var colorGrid: some View {
        VStack(spacing: 16) {
            // Prima riga (5 colori)
            HStack(spacing: 16) {
                ColorButton(color: Colors.categoriaCibo, isSelected: selectedColor == Colors.categoriaCibo) {
                    selectedColor = Colors.categoriaCibo
                }
                ColorButton(color: Colors.categoriaMacchina, isSelected: selectedColor == Colors.categoriaMacchina) {
                    selectedColor = Colors.categoriaMacchina
                }
                ColorButton(color: Colors.categoriaSvago, isSelected: selectedColor == Colors.categoriaSvago) {
                    selectedColor = Colors.categoriaSvago
                }
                ColorButton(color: Colors.categoriaCasa, isSelected: selectedColor == Colors.categoriaCasa) {
                    selectedColor = Colors.categoriaCasa
                }
                ColorButton(color: Colors.categoriaShopping, isSelected: selectedColor == Colors.categoriaShopping) {
                    selectedColor = Colors.categoriaShopping
                }
            }
            // Seconda riga (5 colori)
            HStack(spacing: 16) {
                ColorButton(color: Colors.categoriaSalute, isSelected: selectedColor == Colors.categoriaSalute) {
                    selectedColor = Colors.categoriaSalute
                }
                ColorButton(color: Colors.categoriaStipendio, isSelected: selectedColor == Colors.categoriaStipendio) {
                    selectedColor = Colors.categoriaStipendio
                }
                ColorButton(color: Colors.categoriaRegalo, isSelected: selectedColor == Colors.categoriaRegalo) {
                    selectedColor = Colors.categoriaRegalo
                }
                ColorButton(color: Colors.categoriaBonus, isSelected: selectedColor == Colors.categoriaBonus) {
                    selectedColor = Colors.categoriaBonus
                }
                ColorButton(color: Colors.categoriaBonus2, isSelected: selectedColor == Colors.categoriaBonus2) {
                    selectedColor = Colors.categoriaBonus2
                }
            }
        }
    }
    
    // MARK: - Emoji Grid
    private var emojiGrid: some View {
        VStack(spacing: 16) {
            // Prima riga (5 emoji)
            HStack(spacing: 16) {
                EmojiButton(emoji: "🍖", isSelected: selectedEmoji == "🍖") {
                    selectedEmoji = "🍖"
                }
                EmojiButton(emoji: "🚙", isSelected: selectedEmoji == "🚙") {
                    selectedEmoji = "🚙"
                }
                EmojiButton(emoji: "🍿", isSelected: selectedEmoji == "🍿") {
                    selectedEmoji = "🍿"
                }
                EmojiButton(emoji: "🏡", isSelected: selectedEmoji == "🏡") {
                    selectedEmoji = "🏡"
                }
                EmojiButton(emoji: "🛍️", isSelected: selectedEmoji == "🛍️") {
                    selectedEmoji = "🛍️"
                }
            }
            
            // Seconda riga (5 emoji)
            HStack(spacing: 16) {
                EmojiButton(emoji: "🫀", isSelected: selectedEmoji == "🫀") {
                    selectedEmoji = "🫀"
                }
                EmojiButton(emoji: "💼", isSelected: selectedEmoji == "💼") {
                    selectedEmoji = "💼"
                }
                EmojiButton(emoji: "🎁", isSelected: selectedEmoji == "🎁") {
                    selectedEmoji = "🎁"
                }
                EmojiButton(emoji: "💸", isSelected: selectedEmoji == "💸") {
                    selectedEmoji = "💸"
                }
                EmojiButton(emoji: "💰", isSelected: selectedEmoji == "💰") {
                    selectedEmoji = "💰"
                }
            }
            
            // Terza riga (5 emoji aggiuntive)
            HStack(spacing: 16) {
                EmojiButton(emoji: "🍕", isSelected: selectedEmoji == "🍕") {
                    selectedEmoji = "🍕"
                }
                EmojiButton(emoji: "🎬", isSelected: selectedEmoji == "🎬") {
                    selectedEmoji = "🎬"
                }
                EmojiButton(emoji: "✈️", isSelected: selectedEmoji == "✈️") {
                    selectedEmoji = "✈️"
                }
                EmojiButton(emoji: "🎮", isSelected: selectedEmoji == "🎮") {
                    selectedEmoji = "🎮"
                }
                EmojiButton(emoji: "📱", isSelected: selectedEmoji == "📱") {
                    selectedEmoji = "📱"
                }
            }
            
            // Quarta riga (5 emoji aggiuntive)
            HStack(spacing: 16) {
                EmojiButton(emoji: "🏋️", isSelected: selectedEmoji == "🏋️") {
                    selectedEmoji = "🏋️"
                }
                EmojiButton(emoji: "🎨", isSelected: selectedEmoji == "🎨") {
                    selectedEmoji = "🎨"
                }
                EmojiButton(emoji: "🚗", isSelected: selectedEmoji == "🚗") {
                    selectedEmoji = "🚗"
                }
                EmojiButton(emoji: "🍔", isSelected: selectedEmoji == "🍔") {
                    selectedEmoji = "🍔"
                }
                EmojiButton(emoji: "🎵", isSelected: selectedEmoji == "🎵") {
                    selectedEmoji = "🎵"
                }
            }
        }
    }
    
    // MARK: - Emoji Button
    private struct EmojiButton: View {
        let emoji: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Colors.primaryBackground)
                        .frame(width: 60, height: 60)
                    
                    Text(emoji)
                        .font(.system(size: 24))
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Colors.primaryColor, lineWidth: 2)
                            .frame(width: 60, height: 60) // Forza la dimensione anche per il bordo selezionato
                    }
                }
                .frame(width: 60, height: 60) // Forza la dimensione anche per l'intero ZStack
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Colors.primaryColor : Colors.outlineColor, lineWidth: isSelected ? 0 : 1)
                        .frame(width: 60, height: 60)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Color Button
    private struct ColorButton: View {
        let color: Color
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .frame(width: 60, height: 60)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Colors.primaryColor : Colors.outlineColor, lineWidth: isSelected ? 2 : 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 0) {
            // Striscia con Spesa/Entrata/Modifica
            HStack(spacing: 0) {
                Text(existingCategory != nil ? "Modifica" : (isExpense ? "Spesa" : "Entrata"))
                    .font(AppFonts.headline)
                    .foregroundColor(Colors.primaryText)
            }
            .padding(.bottom, 8)
            
            // Header con pulsanti
            HStack {
                // Tasto X a sinistra
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isClosing = true
                    }
                }) {
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
                
                Spacer()
                
                // Pulsanti a destra
                HStack(spacing: 8) {
                    // Pulsante Cestino (solo in modalità modifica)
                    if existingCategory != nil && onDeleteCategory != nil {
                        Button(action: {
                            deleteCategory()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Colors.errorText)
                                .frame(width: 44, height: 44)
                                .background(Colors.error)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Colors.errorText.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Pulsante Conferma
                    Button(action: {
                        // Validazione e salvataggio
                        if validateFields() {
                            saveCategory()
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Colors.primaryBackground)
                            .frame(width: 44, height: 44)
                            .background(Colors.primaryColor)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 20)
        .allowsHitTesting(true)
    }
}

#if DEBUG
#Preview {
    CategoryView(isExpense: true, existingCategory: nil, onDismiss: {
        // Placeholder for onDismiss action
    }, onSaveCategory: { _ in
        // Placeholder for onSaveCategory action
    }, onDeleteCategory: { _ in
        // Placeholder for onDeleteCategory action
    })
}
#endif 
