import SwiftUI

struct MainScrollContent: View {
    let periodDescription: String
    let netTotal: Double
    let dragOffset: CGFloat
    let filteredTransactions: [Transaction]
    @Binding var selectedCategory: String?
    let isEmpty: Bool
    let upcomingTransactions: [Transaction]
    let groupedTransactions: [Date: [Transaction]]
    let expenses: Double
    let income: Double

    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: (CGFloat) -> Void
    let onTransactionTap: (Transaction) -> Void
    let onScrollOffsetChanged: (CGFloat) -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TotalAmountSection(
                        periodDescription: periodDescription,
                        netTotal: netTotal,
                        dragOffset: dragOffset,
                        onDragChanged: onDragChanged,
                        onDragEnded: onDragEnded
                    )
                    .id("categorySection")
                    
                    if isEmpty {
                        EmptyStateView()
                    } else {
                        // Card Entrate e Spese
                        IncomeExpenseCards(expenses: expenses, income: income)
                            .padding(.top, 16)
                            .padding(.bottom, 6) // Aggiunto spazio sotto i rettangoli
                        
                        TransactionListView(
                            upcomingTransactions: upcomingTransactions,
                            groupedTransactions: groupedTransactions,
                            selectedCategory: selectedCategory,
                            onTransactionTap: onTransactionTap
                        )
                    }
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.frame(in: .named("scroll"))) { _, newFrame in
                                let offset = newFrame.minY
                                onScrollOffsetChanged(offset)
                            }
                    }
                )
            }
            .coordinateSpace(name: "scroll")
        }
    }
}

// MARK: - Supporting Views
private struct TotalAmountSection: View {
    let periodDescription: String
    let netTotal: Double
    let dragOffset: CGFloat
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: (CGFloat) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(periodDescription)
                .font(AppFonts.headline2)
                .foregroundColor(Colors.secondaryText)
                .padding(.bottom, 8)
            
            AmountDisplay(netTotal: netTotal)
        }
        .padding(.top, 40)
        .padding(.bottom, 35)
        .background(
            ZStack {
                Rectangle()
                    .fill(Colors.primaryBackground) // Sfondo bianco
                    .frame(width: 200, height: 120)
                    .cornerRadius(12)
                
                // Griglia con outline e sfumatura sui lati
                GridPattern()
                    .stroke(Colors.limeGreen , lineWidth: 1)
                    .frame(width: 340, height: 150) // Griglia più larga a destra e sinistra
                    .opacity(0.25) // Opacità al 50%
                    .mask(
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3), Color.white, Color.white.opacity(0.3), Color.clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .scaleEffect(x: 1.5, y: 0.85) // Ovale più largo orizzontalmente
                    )
                
                // Quadrati colorati randomicamente
                ColoredSquaresPattern()
                    .fill(Colors.limeGreen)
                    .frame(width: 340, height: 150)
                    .opacity(0.09)
                    .mask(
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.3), Color.white, Color.white.opacity(0.3), Color.clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .scaleEffect(x: 1.5, y: 0.9)
                    )
            }
        )
        .offset(x: dragOffset * 0.1)
        .gesture(swipeGesture)
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                onDragChanged(value.translation.width)
            }
            .onEnded { value in
                onDragEnded(value.translation.width)
            }
    }
}

private struct AmountDisplay: View {
    let netTotal: Double
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if netTotal < 0 {
                Text("-")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
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
}

private struct TransactionListView: View {
    let upcomingTransactions: [Transaction]
    let groupedTransactions: [Date: [Transaction]]
    let selectedCategory: String?
    let onTransactionTap: (Transaction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !upcomingTransactions.isEmpty {
                FutureTransactionsSection(
                    transactions: upcomingTransactions,
                    selectedCategory: selectedCategory,
                    onTransactionTap: onTransactionTap
                )
            }
            
            PastTransactionsSection(
                groupedTransactions: groupedTransactions,
                selectedCategory: selectedCategory,
                onTransactionTap: onTransactionTap
            )
        }
    }
}

private struct FutureTransactionsSection: View {
    let transactions: [Transaction]
    let selectedCategory: String?
    let onTransactionTap: (Transaction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "IN FUTURO", isFuture: true)
            
            ForEach(transactions) { transaction in
                TransactionRow(
                    transaction: transaction,
                    isFuture: true,
                    selectedCategory: selectedCategory
                ) {
                    triggerHapticFeedback()
                    onTransactionTap(transaction)
                }
            }
        }
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

private struct PastTransactionsSection: View {
    let groupedTransactions: [Date: [Transaction]]
    let selectedCategory: String?
    let onTransactionTap: (Transaction) -> Void
    
    var body: some View {
        ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
            let dayTransactions = groupedTransactions[date] ?? []
            let dayBalance = dayTransactions.reduce(0) { $0 + $1.amount }
            
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(
                    title: date.formattedSection,
                    balance: dayBalance,
                    isFuture: false
                )
                
                ForEach(dayTransactions) { transaction in
                    TransactionRow(
                        transaction: transaction,
                        isFuture: false,
                        selectedCategory: selectedCategory
                    ) {
                        triggerHapticFeedback()
                        onTransactionTap(transaction)
                    }
                }
            }
        }
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Grid Pattern
struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let gridSize: CGFloat = 30 // Dimensione delle celle della griglia (leggermente più piccola)
        
        // Linee verticali
        for x in stride(from: 0, through: rect.width, by: gridSize) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Linee orizzontali
        for y in stride(from: 0, through: rect.height, by: gridSize) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

// MARK: - Colored Squares Pattern
struct ColoredSquaresPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let gridSize: CGFloat = 30
        let randomSquares = generateRandomSquares(in: rect, gridSize: gridSize)
        
        for square in randomSquares {
            let squarePath = Path(CGRect(x: square.minX, y: square.minY, width: gridSize, height: gridSize))
            path.addPath(squarePath)
        }
        
        return path
    }
    
    private func generateRandomSquares(in rect: CGRect, gridSize: CGFloat) -> [CGRect] {
        var squares: [CGRect] = []
        var random = RandomNumberGenerator()
        
        let cols = Int(rect.width / gridSize)
        let rows = Int(rect.height / gridSize)
        
        for row in 0..<rows {
            for col in 0..<cols {
                // 30% di probabilità che un quadrato sia colorato
                if random.next() < 0.30 {
                    let x = CGFloat(col) * gridSize
                    let y = CGFloat(row) * gridSize
                    squares.append(CGRect(x: x, y: y, width: gridSize, height: gridSize))
                }
            }
        }
        
        return squares
    }
}

// MARK: - Random Number Generator
struct RandomNumberGenerator {
    private var seed: UInt64
    
    init() {
        self.seed = UInt64(Date().timeIntervalSince1970)
    }
    
    mutating func next() -> Double {
        seed = seed &* 6364136223846793005 &+ 1
        return Double(seed >> 16) / Double(UInt64.max >> 16)
    }
}


