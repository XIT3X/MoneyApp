import SwiftUI

struct CategoryPercentage {
    let category: String
    let amount: Double
    let percentage: Double
}

struct CategoryDistributionBar: View {
    let transactions: [Transaction]
    @Binding var selectedCategory: String?
    
    private var totalExpense: Double {
        abs(transactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
    }
    
    private var totalIncome: Double {
        transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        TabView {
            ExpenseDistributionView(
                transactions: transactions,
                selectedCategory: $selectedCategory,
                totalExpense: totalExpense
            )
            .tag(0)
            
            IncomeDistributionView(
                transactions: transactions,
                selectedCategory: $selectedCategory,
                totalIncome: totalIncome
            )
            .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 108)
    }
}

// MARK: - Expense Distribution
private struct ExpenseDistributionView: View {
    let transactions: [Transaction]
    @Binding var selectedCategory: String?
    let totalExpense: Double
    
    private var categoryPercentages: [CategoryPercentage] {
        CategoryCalculator.calculateExpensePercentages(from: transactions)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            DistributionHeader(title: "Spese", total: totalExpense)
            
            if !categoryPercentages.isEmpty {
                CategoryBarView(
                    percentages: categoryPercentages,
                    selectedCategory: $selectedCategory
                )
                
                CategoryScrollView(
                    percentages: categoryPercentages,
                    selectedCategory: $selectedCategory
                )
            } else {
                EmptyDistributionView(
                    message: "Nessuna spesa in questo periodo",
                    showMessage: !transactions.isEmpty
                )
            }
        }
    }
}

// MARK: - Income Distribution
private struct IncomeDistributionView: View {
    let transactions: [Transaction]
    @Binding var selectedCategory: String?
    let totalIncome: Double
    
    private var categoryPercentages: [CategoryPercentage] {
        CategoryCalculator.calculateIncomePercentages(from: transactions)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            DistributionHeader(title: "Entrate", total: totalIncome)
            
            if !categoryPercentages.isEmpty {
                CategoryBarView(
                    percentages: categoryPercentages,
                    selectedCategory: $selectedCategory
                )
                
                CategoryScrollView(
                    percentages: categoryPercentages,
                    selectedCategory: $selectedCategory
                )
            } else {
                EmptyDistributionView(
                    message: "Nessuna entrata in questo periodo",
                    showMessage: !transactions.isEmpty
                )
            }
        }
    }
}

// MARK: - Supporting Views
private struct DistributionHeader: View {
    let title: String
    let total: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.headline2)
                .foregroundColor(Colors.secondaryText)
            Spacer()
            Text(total.formattedAmount + " €")
                .font(AppFonts.headline2)
                .foregroundColor(Colors.secondaryText)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 4)
    }
}

private struct CategoryBarView: View {
    let percentages: [CategoryPercentage]
    @Binding var selectedCategory: String?
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 5) {
                ForEach(Array(percentages.enumerated()), id: \.element.category) { index, item in
                    CategoryBarItem(
                        item: item,
                        geometry: geometry,
                        categoryCount: percentages.count,
                        index: index,
                        isSelected: selectedCategory == item.category,
                        selectedCategory: selectedCategory,
                        onTap: { toggleCategory(item.category) }
                    )
                }
            }
            .frame(height: 30)
            .cornerRadius(6)
            .clipped()
        }
        .frame(height: 30)
        .padding(.horizontal, 30)
    }
    
    private func toggleCategory(_ category: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedCategory = selectedCategory == category ? nil : category
        }
    }
}

private struct CategoryScrollView: View {
    let percentages: [CategoryPercentage]
    @Binding var selectedCategory: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(percentages.enumerated()), id: \.element.category) { index, item in
                    CategoryListItem(
                        item: item,
                        index: index,
                        isSelected: selectedCategory == item.category,
                        selectedCategory: selectedCategory,
                        onTap: { toggleCategory(item.category) }
                    )
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 6)
    }
    
    private func toggleCategory(_ category: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedCategory = selectedCategory == category ? nil : category
        }
    }
}

private struct EmptyDistributionView: View {
    let message: String
    let showMessage: Bool
    
    var body: some View {
        Rectangle()
            .fill(Colors.outlineColor.opacity(0.3))
            .frame(height: 30)
            .cornerRadius(6)
            .padding(.horizontal, 30)
            .padding(.bottom, 6)
        
        if showMessage {
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Colors.secondaryText)
                .padding(.top, 6)
                .padding(.horizontal, 30)
        }
    }
}

// MARK: - Category Calculator
private struct CategoryCalculator {
    static func calculateExpensePercentages(from transactions: [Transaction]) -> [CategoryPercentage] {
        let totalExpense = abs(transactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount })
        
        guard totalExpense > 0 else { return [] }
        
        var categoryTotals: [String: Double] = [:]
        for transaction in transactions where transaction.amount < 0 {
            categoryTotals[transaction.category, default: 0] += abs(transaction.amount)
        }
        
        return categoryTotals.map { (category, amount) in
            CategoryPercentage(
                category: category,
                amount: amount,
                percentage: amount / totalExpense
            )
        }.sorted { first, second in
            if abs(first.percentage - second.percentage) > 0.001 {
                return first.percentage > second.percentage
            }
            return first.category < second.category
        }
    }
    
    static func calculateIncomePercentages(from transactions: [Transaction]) -> [CategoryPercentage] {
        let totalIncome = transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        
        guard totalIncome > 0 else { return [] }
        
        var categoryTotals: [String: Double] = [:]
        for transaction in transactions where transaction.amount > 0 {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals.map { (category, amount) in
            CategoryPercentage(
                category: category,
                amount: amount,
                percentage: amount / totalIncome
            )
        }.sorted { first, second in
            if abs(first.percentage - second.percentage) > 0.001 {
                return first.percentage > second.percentage
            }
            return first.category < second.category
        }
    }
}