import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let isFuture: Bool
    let selectedCategory: String?
    let onTap: (() -> Void)?
    
    @State private var isLongPressCompleted = false
    @State private var isLongPressing = false
    
    init(
        transaction: Transaction,
        isFuture: Bool = false,
        selectedCategory: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.transaction = transaction
        self.isFuture = isFuture
        self.selectedCategory = selectedCategory
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: 14) {
            TransactionIcon(transaction: transaction, isFuture: isFuture)
            TransactionDetails(transaction: transaction, isFuture: isFuture)
            Spacer()
            TransactionAmount(transaction: transaction, isFuture: isFuture)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Colors.primaryBackground)
        .opacity(isVisible ? 1.0 : 0.3)
        .scaleEffect(isLongPressing ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLongPressCompleted)
        .animation(.easeInOut(duration: 0.15), value: isLongPressing)
        .onLongPressGesture(
            minimumDuration: 0.5,
            maximumDistance: 50,
            perform: handleLongPress,
            onPressingChanged: { pressing in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isLongPressing = pressing
                }
            }
        )
    }
    
    // MARK: - Computed Properties
    private var isVisible: Bool {
        selectedCategory == nil || selectedCategory == transaction.category
    }
    

    
    // MARK: - Gesture Handlers
    private func handleLongPress() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLongPressCompleted = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onTap?()
            isLongPressCompleted = false
            isLongPressing = false
        }
    }
    

}

// MARK: - Supporting Views
private struct TransactionIcon: View {
    let transaction: Transaction
    let isFuture: Bool
    
    var body: some View {
        ZStack {
            iconBackground
            iconEmoji
        }
    }
    
    private var iconBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundFill)
            .frame(width: 44, height: 44)
            .overlay(borderOverlay)
            .opacity(isFuture ? 0.6 : 1.0)
    }
    
    private var backgroundFill: Color {
        Colors.primaryBackground // Always white background for all category icons
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(borderColor, lineWidth: borderWidth)
    }
    
    private var borderColor: Color {
        Colors.outlineColor
    }
    
    private var borderWidth: CGFloat {
        isFuture ? 1 : 1
    }
    
    private var iconEmoji: some View {
        Text(categoryEmoji(for: transaction.category))
            .font(.system(size: 20))
            .opacity(isFuture ? 0.6 : 1.0)
    }
}

private struct TransactionDetails: View {
    let transaction: Transaction
    let isFuture: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            primaryText
            secondaryText
        }
    }
    
    private var primaryText: some View {
        Text(primaryTextContent)
            .font(.system(size: 17, weight: .regular, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(primaryTextColor)
    }
    
    private var secondaryText: some View {
        Text(secondaryTextContent)
            .fontWeight(.medium)
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(Colors.secondaryText)
    }
    
    private var primaryTextContent: String {
        transaction.description.isEmpty ? transaction.category : transaction.description
    }
    
    private var secondaryTextContent: String {
        isFuture ? transaction.date.formattedDate : transaction.category
    }
    
    private var primaryTextColor: Color {
        isFuture ? Colors.secondaryText : Colors.primaryText
    }
}

private struct TransactionAmount: View {
    let transaction: Transaction
    let isFuture: Bool
    
    var body: some View {
        Text(formattedAmount)
            .fontWeight(.semibold)
            .font(.system(size: 19, weight: .regular, design: .rounded))
            .foregroundColor(amountColor)
    }
    
    private var formattedAmount: String {
        let sign = transaction.amount >= 0 ? "+" : ""
        return "\(sign)\(transaction.amount.formattedAmount) €"
    }
    
    private var amountColor: Color {
        if isFuture {
            return Colors.secondaryText
        } else {
                            return transaction.amount >= 0 ? Color(hex: "#9acd32") : Colors.primaryText
        }
    }
}