import SwiftUI

struct CurrencyDropdown: View {
    @Binding var isExpanded: Bool
    @Binding var selectedCurrency: Currency
    let onCurrencySelected: (Currency) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    Text("Valuta")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.primaryText)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(selectedCurrency.name)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Colors.secondaryText)
                        
                        Text(selectedCurrency.symbol)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Colors.secondaryText)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.secondaryText)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 8)
                .background(Colors.primaryBackground)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dropdown content
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        Button(action: {
                            selectedCurrency = currency
                            onCurrencySelected(currency)
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded = false
                            }
                        }) {
                            HStack(spacing: 14) {
                                Text(currency.name)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Colors.primaryText)
                                
                                Text(currency.symbol)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Colors.secondaryText)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(selectedCurrency == currency ? Colors.primaryColor.opacity(0.1) : Colors.primaryBackground)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if currency != Currency.allCases.last {
                            Rectangle()
                                .fill(Colors.outlineColor)
                                .frame(height: 0.5)
                                .padding(.horizontal, 30)
                        }
                    }
                }
                .background(Colors.primaryBackground)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#if DEBUG
struct CurrencyDropdown_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyDropdown(
            isExpanded: .constant(true),
            selectedCurrency: .constant(.euro)
        ) { currency in
            print("Selected currency: \(currency)")
        }
        .background(Colors.primaryBackground)
    }
}
#endif 