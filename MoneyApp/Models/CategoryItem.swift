import SwiftUI

// MARK: - Modello Categoria
struct CategoryItem: Identifiable {
    let id: UUID
    let name: String
    let color: Color
    let emoji: String
    
    init(id: UUID = UUID(), name: String, color: Color, emoji: String) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
    }
} 