import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let description: String
    let amount: Double
    let category: String
    let date: Date
    
    init(id: UUID = UUID(), description: String, amount: Double, category: String, date: Date) {
        self.id = id
        self.description = description
        self.amount = amount
        self.category = category
        self.date = date
    }
} 