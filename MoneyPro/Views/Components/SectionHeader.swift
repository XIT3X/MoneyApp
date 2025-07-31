import SwiftUI

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
            headerContent
            divider
        }
    }
    
    private var headerContent: some View {
        HStack {
            titleText
            Spacer()
            balanceText
        }
        .padding(.horizontal, 30)
        .padding(.top, 25)
        .padding(.bottom, 5.5)
    }
    
    private var titleText: some View {
        Text(title)
            .font(AppFonts.headline2)
            .foregroundColor(Colors.secondaryText)
    }
    
    @ViewBuilder
    private var balanceText: some View {
        if let balance = balance {
            Text(balance.formattedAmount + " €")
                .font(AppFonts.headline2)
                .foregroundColor(Colors.secondaryText)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Colors.outlineColor)
            .frame(height: 1.2)
            .padding(.horizontal, 30)
            .padding(.bottom, 7.5)
    }
}