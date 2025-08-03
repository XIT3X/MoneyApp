import SwiftUI

struct IncomeExpenseCards: View {
    let expenses: Double
    let income: Double
    let onExpenseTap: () -> Void
    let onIncomeTap: () -> Void
    let onAddTransaction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Card Spese
                ExpenseCard(amount: expenses, onTap: onExpenseTap)
                
                // Card Entrate
                IncomeCard(amount: income, onTap: onIncomeTap)
            }
            
            // Pulsante per aggiungere transazione
            AddTransactionButton(action: onAddTransaction)
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 20)
    }
}

private struct ExpenseCard: View {
    let amount: Double
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Spese")
                    .font(AppFonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Colors.secondaryText)
                
                Spacer()
                
                Image(systemName: "arrow.down.right")
                    .foregroundColor(Colors.errorText)
                    .font(.title3)
            }
            
            Text(amount.formattedAmount)
                .font(AppFonts.headline)
                .fontWeight(.bold)
                .foregroundColor(Colors.primaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Colors.primaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Colors.outlineColor, lineWidth: 2)
                )
                .overlay(
                    // Linea obliqua che divide in 3/4 (direzione opposta)
                    Rectangle()
                        .stroke(Colors.outlineColor, lineWidth: 1)
                        .fill(Colors.error.opacity(0.3))
                        .frame(width: 100, height: 150)
                        .rotationEffect(.degrees(-15)) // Linea obliqua in direzione opposta
                        .offset(x: 75) // Posizione approssimativa per 3/4
                )

        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Colors.outlineColor.opacity(0.25), radius: 10, x: 0, y: 0)
        .onTapGesture {
            onTap()
        }
    }
}

private struct IncomeCard: View {
    let amount: Double
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Entrate")
                    .font(AppFonts.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Colors.secondaryText)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .foregroundColor(Colors.limeGreenText)
                    .font(.title3)
            }
            
            Text(amount.formattedAmount)
                .font(AppFonts.headline)
                .fontWeight(.bold)
                .foregroundColor(Colors.primaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Colors.primaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Colors.outlineColor, lineWidth:  2)
                )
                .overlay(
                    // Linea obliqua che divide in 3/4 (direzione opposta)
                    Rectangle()
                        .stroke(Colors.outlineColor, lineWidth: 1)
                        .fill(Colors.limeGreen.opacity(0.3))
                        .frame(width: 100, height: 150)
                        .rotationEffect(.degrees(-15)) // Linea obliqua in direzione opposta
                        .offset(x: 75) // Posizione approssimativa per 3/4
                )

        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Colors.outlineColor.opacity(0.25), radius: 10, x: 0, y: 0)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Add Transaction Button with Scaling Animation
private struct AddTransactionButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Image(systemName: "plus")
                    .foregroundColor(Colors.primaryText)
                    .font(.system(size: 16, weight: .medium))
                
                Text("Aggiungi una transazione")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Colors.primaryText)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Colors.primaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Colors.outlineColor, lineWidth: 2)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Colors.outlineColor.opacity(0.25), radius: 10, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.99 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
