import SwiftUI

// MARK: - Category Functions
func categoryEmoji(for category: String) -> String {
    // Check custom categories first
    if let customCategory = findCustomCategory(by: category) {
        return customCategory.emoji
    }
    
    // Default categories
    switch category.lowercased() {
    case "cibo": return "🍖"
    case "macchina": return "🚙"
    case "svago": return "🍿"
    case "casa": return "🏡"
    case "shopping": return "🛍️"
    case "salute": return "🫀"
    case "trasporti": return "🚌"
    case "sport": return "⚽"
    case "viaggi": return "✈️"
    case "animali": return "🐕"
    case "spesa": return "🛒"
    case "regali": return "🎁"
    case "stipendio": return "💼"
    case "regalo": return "🎁"
    case "bonus": return "💸"
    case "investimenti": return "📈"
    default: return "🏷️"
    }
}

func categoryColor(for category: String) -> Color {
    // Return lime green for all categories
    return Colors.limeGreen
}

// MARK: - Custom Category Functions
func findCustomCategory(by name: String) -> CategoryItem? {
    let allCustomCategories = loadCustomCategories()
    return allCustomCategories.first { $0.name.lowercased() == name.lowercased() }
}

func loadCustomCategories() -> [CategoryItem] {
    var allCategories: [CategoryItem] = []
    
    // Load custom expense categories
    if let expenseData = UserDefaults.standard.array(forKey: "customExpenseCategories") as? [[String: Any]] {
        let expenseCategories = expenseData.compactMap(createCategoryItem)
        allCategories.append(contentsOf: expenseCategories)
    }
    
    // Load custom income categories
    if let incomeData = UserDefaults.standard.array(forKey: "customIncomeCategories") as? [[String: Any]] {
        let incomeCategories = incomeData.compactMap(createCategoryItem)
        allCategories.append(contentsOf: incomeCategories)
    }
    
    return allCategories
}

private func createCategoryItem(from data: [String: Any]) -> CategoryItem? {
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

func hexToColor(_ hex: String) -> Color {
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