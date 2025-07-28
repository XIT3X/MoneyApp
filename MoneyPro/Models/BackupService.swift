import Foundation
import SwiftUI

class BackupService: ObservableObject {
    static let shared = BackupService()
    
    private let backupFileName = "money_manager_backup.json"
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private init() {}
    
    // MARK: - Backup Automatico
    
    func createAutomaticBackup() {
        guard let backupData = CoreDataManager.shared.createBackup() else {
            print("Impossibile creare il backup")
            return
        }
        
        let backupURL = documentsPath.appendingPathComponent(backupFileName)
        
        do {
            try backupData.write(to: backupURL)
            print("Backup automatico creato con successo")
            
            // Salva anche una copia di sicurezza in iCloud se disponibile
            saveToiCloud(backupData)
            
        } catch {
            print("Errore nel salvare il backup: \(error)")
        }
    }
    
    func restoreFromAutomaticBackup() -> Bool {
        let backupURL = documentsPath.appendingPathComponent(backupFileName)
        
        guard FileManager.default.fileExists(atPath: backupURL.path) else {
            print("Nessun backup trovato")
            return false
        }
        
        do {
            let backupData = try Data(contentsOf: backupURL)
            CoreDataManager.shared.restoreFromBackup(backupData)
            print("Backup ripristinato con successo")
            return true
        } catch {
            print("Errore nel ripristinare il backup: \(error)")
            return false
        }
    }
    
    // MARK: - Backup Manuale
    
    func createManualBackup() -> Data? {
        return CoreDataManager.shared.createBackup()
    }
    
    func restoreFromManualBackup(_ data: Data) {
        CoreDataManager.shared.restoreFromBackup(data)
    }
    
    // MARK: - iCloud Backup
    
    private func saveToiCloud(_ data: Data) {
        let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent(backupFileName)
        
        guard let iCloudURL = iCloudURL else {
            print("iCloud non disponibile")
            return
        }
        
        do {
            try data.write(to: iCloudURL)
            print("Backup salvato su iCloud")
        } catch {
            print("Errore nel salvare su iCloud: \(error)")
        }
    }
    
    func restoreFromiCloud() -> Bool {
        let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent(backupFileName)
        
        guard let iCloudURL = iCloudURL,
              FileManager.default.fileExists(atPath: iCloudURL.path) else {
            print("Nessun backup iCloud trovato")
            return false
        }
        
        do {
            let backupData = try Data(contentsOf: iCloudURL)
            CoreDataManager.shared.restoreFromBackup(backupData)
            print("Backup iCloud ripristinato con successo")
            return true
        } catch {
            print("Errore nel ripristinare il backup iCloud: \(error)")
            return false
        }
    }
    
    // MARK: - Utility
    
    func hasBackup() -> Bool {
        let localBackup = documentsPath.appendingPathComponent(backupFileName)
        let iCloudBackup = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent(backupFileName)
        
        return FileManager.default.fileExists(atPath: localBackup.path) ||
               (iCloudBackup != nil && FileManager.default.fileExists(atPath: iCloudBackup!.path))
    }
    
    func deleteBackup() {
        let localBackup = documentsPath.appendingPathComponent(backupFileName)
        let iCloudBackup = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
            .appendingPathComponent(backupFileName)
        
        do {
            if FileManager.default.fileExists(atPath: localBackup.path) {
                try FileManager.default.removeItem(at: localBackup)
            }
            
            if let iCloudBackup = iCloudBackup,
               FileManager.default.fileExists(atPath: iCloudBackup.path) {
                try FileManager.default.removeItem(at: iCloudBackup)
            }
            
            print("Backup eliminato con successo")
        } catch {
            print("Errore nell'eliminare il backup: \(error)")
        }
    }
    
    // MARK: - Migrazione da UserDefaults
    
    func migrateFromUserDefaults() {
        // Migra le transazioni
        if let data = UserDefaults.standard.data(forKey: "transactions_key"),
           let transactions = try? JSONDecoder().decode([Transaction].self, from: data) {
            for transaction in transactions {
                CoreDataManager.shared.saveTransaction(transaction)
            }
        }
        
        // Migra le categorie personalizzate
        if let expenseData = UserDefaults.standard.array(forKey: "customExpenseCategories") as? [[String: Any]] {
            for data in expenseData {
                if let idString = data["id"] as? String,
                   let id = UUID(uuidString: idString),
                   let name = data["name"] as? String,
                   let colorHex = data["colorHex"] as? String,
                   let emoji = data["emoji"] as? String {
                    
                    let category = CategoryItem(
                        id: id,
                        name: name,
                        color: Color(hex: colorHex),
                        emoji: emoji
                    )
                    CoreDataManager.shared.saveCategory(category, isExpense: true)
                }
            }
        }
        
        if let incomeData = UserDefaults.standard.array(forKey: "customIncomeCategories") as? [[String: Any]] {
            for data in incomeData {
                if let idString = data["id"] as? String,
                   let id = UUID(uuidString: idString),
                   let name = data["name"] as? String,
                   let colorHex = data["colorHex"] as? String,
                   let emoji = data["emoji"] as? String {
                    
                    let category = CategoryItem(
                        id: id,
                        name: name,
                        color: Color(hex: colorHex),
                        emoji: emoji
                    )
                    CoreDataManager.shared.saveCategory(category, isExpense: false)
                }
            }
        }
        
        // Crea un backup dopo la migrazione
        createAutomaticBackup()
        
        print("Migrazione da UserDefaults completata")
    }
} 