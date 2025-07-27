import Foundation
import CoreData
import SwiftUI

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "MoneyManager")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Configura per salvare automaticamente i cambiamenti
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Backup e Ripristino
    
    func createBackup() -> Data? {
        let context = container.viewContext
        
        // Crea un backup delle transazioni
        let transactionRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let transactions = try context.fetch(transactionRequest)
            let categories = try context.fetch(categoryRequest)
            
            let backup = BackupData(
                transactions: transactions.map { entity in
                    Transaction(
                        id: entity.id ?? UUID(),
                        description: entity.desc ?? "",
                        amount: entity.amount,
                        category: entity.category ?? "",
                        date: entity.date ?? Date()
                    )
                },
                categories: categories.map { entity in
                    CategoryItemBackup(from: CategoryItem(
                        id: entity.id ?? UUID(),
                        name: entity.name ?? "",
                        color: Color(hex: entity.colorHex ?? "#ffbeaa"),
                        emoji: entity.emoji ?? ""
                    ))
                }
            )
            
            return try JSONEncoder().encode(backup)
        } catch {
            print("Errore nel creare il backup: \(error)")
            return nil
        }
    }
    
    func restoreFromBackup(_ data: Data) {
        do {
            let backup = try JSONDecoder().decode(BackupData.self, from: data)
            
            // Pulisci i dati esistenti
            clearAllData()
            
            // Ripristina le transazioni
            for transaction in backup.transactions {
                saveTransaction(transaction)
            }
            
            // Ripristina le categorie
            for categoryBackup in backup.categories {
                let category = categoryBackup.toCategoryItem()
                saveCategory(category, isExpense: true) // Assumiamo che siano spese per default
            }
            
            // Salva i cambiamenti
            saveContext()
            
        } catch {
            print("Errore nel ripristinare il backup: \(error)")
        }
    }
    
    func clearAllData() {
        let context = container.viewContext
        
        // Elimina tutte le transazioni
        let transactionRequest: NSFetchRequest<NSFetchRequestResult> = TransactionEntity.fetchRequest()
        let deleteTransactionRequest = NSBatchDeleteRequest(fetchRequest: transactionRequest)
        
        // Elimina tutte le categorie
        let categoryRequest: NSFetchRequest<NSFetchRequestResult> = CategoryEntity.fetchRequest()
        let deleteCategoryRequest = NSBatchDeleteRequest(fetchRequest: categoryRequest)
        
        do {
            try context.execute(deleteTransactionRequest)
            try context.execute(deleteCategoryRequest)
            try context.save()
        } catch {
            print("Errore nel cancellare i dati: \(error)")
        }
    }
    
    // MARK: - Gestione Transazioni
    
    func saveTransaction(_ transaction: Transaction) {
        let context = container.viewContext
        let entity = TransactionEntity(context: context)
        
        entity.id = transaction.id
        entity.desc = transaction.description
        entity.amount = transaction.amount
        entity.category = transaction.category
        entity.date = transaction.date
        
        saveContext()
    }
    
    func loadTransactions() -> [Transaction] {
        let context = container.viewContext
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                Transaction(
                    id: entity.id ?? UUID(),
                    description: entity.desc ?? "",
                    amount: entity.amount,
                    category: entity.category ?? "",
                    date: entity.date ?? Date()
                )
            }
        } catch {
            print("Errore nel caricare le transazioni: \(error)")
            return []
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        let context = container.viewContext
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            saveContext()
        } catch {
            print("Errore nel cancellare la transazione: \(error)")
        }
    }
    
    func updateTransaction(_ transaction: Transaction) {
        deleteTransaction(transaction)
        saveTransaction(transaction)
    }
    
    // MARK: - Gestione Categorie
    
    func saveCategory(_ category: CategoryItem, isExpense: Bool) {
        let context = container.viewContext
        let entity = CategoryEntity(context: context)
        
        entity.id = category.id
        entity.name = category.name
        entity.colorHex = colorToHex(category.color)
        entity.emoji = category.emoji
        entity.isExpense = isExpense
        
        saveContext()
    }
    
    func loadCategories(isExpense: Bool) -> [CategoryItem] {
        let context = container.viewContext
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isExpense == %@", NSNumber(value: isExpense))
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                CategoryItem(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    color: Color(hex: entity.colorHex ?? "#ffbeaa"),
                    emoji: entity.emoji ?? ""
                )
            }
        } catch {
            print("Errore nel caricare le categorie: \(error)")
            return []
        }
    }
    
    func deleteCategory(_ category: CategoryItem) {
        let context = container.viewContext
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            saveContext()
        } catch {
            print("Errore nel cancellare la categoria: \(error)")
        }
    }
    
    // MARK: - Utility
    
    private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Errore nel salvare il contesto: \(error)")
            }
        }
    }
    
    private func colorToHex(_ color: Color) -> String {
        // Converti i colori predefiniti in hex
        switch color {
        case Colors.categoriaCibo: return "#ffbeaa"
        case Colors.categoriaMacchina: return "#9acdf9"
        case Colors.categoriaSvago: return "#addab0"
        case Colors.categoriaCasa: return "#ffd08c"
        case Colors.categoriaShopping: return "#f499b7"
        case Colors.categoriaSalute: return "#f9aaa5"
        case Colors.categoriaStipendio: return "#c0b2ab"
        case Colors.categoriaRegalo: return "#cfbee7"
        case Colors.categoriaBonus: return "#d19eda"
        case Colors.categoriaBonus2: return "#9ed7da"
        case Colors.incoming: return "#00B4D8"
        default: return "#ffbeaa" // Default
        }
    }
}

// MARK: - Modello Backup

struct BackupData: Codable {
    let transactions: [Transaction]
    let categories: [CategoryItemBackup]
}

// MARK: - Modello Backup per Categorie
struct CategoryItemBackup: Codable {
    let id: UUID
    let name: String
    let colorHex: String
    let emoji: String
    
    init(from category: CategoryItem) {
        self.id = category.id
        self.name = category.name
        self.colorHex = CategoryItemBackup.colorToHex(category.color)
        self.emoji = category.emoji
    }
    
    func toCategoryItem() -> CategoryItem {
        return CategoryItem(
            id: id,
            name: name,
            color: Color(hex: colorHex),
            emoji: emoji
        )
    }
    
    private static func colorToHex(_ color: Color) -> String {
        // Converti i colori predefiniti in hex
        switch color {
        case Colors.categoriaCibo: return "#ffbeaa"
        case Colors.categoriaMacchina: return "#9acdf9"
        case Colors.categoriaSvago: return "#addab0"
        case Colors.categoriaCasa: return "#ffd08c"
        case Colors.categoriaShopping: return "#f499b7"
        case Colors.categoriaSalute: return "#f9aaa5"
        case Colors.categoriaStipendio: return "#c0b2ab"
        case Colors.categoriaRegalo: return "#cfbee7"
        case Colors.categoriaBonus: return "#d19eda"
        case Colors.categoriaBonus2: return "#9ed7da"
        case Colors.incoming: return "#00B4D8"
        default: return "#ffbeaa" // Default
        }
    }
} 