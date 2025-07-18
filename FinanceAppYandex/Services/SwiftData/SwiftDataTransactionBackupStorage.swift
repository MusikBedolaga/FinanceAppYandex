import Foundation
import SwiftData

enum StorageConfiguration {
    static func createContainer() throws -> ModelContainer {
        try ModelContainer(
            for: TransactionStorage.self,
                 BankAccountStorage.self,
                 CategoryStorage.self,
                 BackupOperationStorage.self
        )
    }
}

actor SwiftDataTransactionBackupStorage: TransactionBackupStorageProtocol {
    private let context: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.context = ModelContext(modelContainer)
        self.context.autosaveEnabled = false
    }

    func load() async throws -> [BackupOperation] {
        let descriptor = FetchDescriptor<BackupOperationStorage>()
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    func addOrUpdate(_ operation: BackupOperation) async throws {
        if let existing = try fetch(by: operation.id) {
            existing.operationType = operation.operationType.rawValue
            existing.transactionData = try? JSONEncoder().encode(operation.transaction)
        } else {
            let storage = BackupOperationStorage(
                id: operation.id,
                operationType: operation.operationType,
                transaction: operation.transaction,
                balanceDelta: operation.balanceDelta
            )
            context.insert(storage)
        }
        try context.save()
    }

    func remove(by id: Int) async throws {
        if let existing = try fetch(by: id) {
            context.delete(existing)
            try context.save()
        }
    }
    
    func removeMany(transactions: [Transaction]) async throws {
        let ids = transactions.map { $0.id }
        let predicate = #Predicate<BackupOperationStorage> { ids.contains($0.id) }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        let itemsToDelete = try context.fetch(descriptor)
            
        for item in itemsToDelete {
            print("🗑 Запрашиваю удаление из backup операций с id: \(ids)")
            print("🗑 Найдено для удаления в backup: \(itemsToDelete.map { $0.id })")
            context.delete(item)
        }
            
        try context.save()
    }
    
    func clearAll() async throws {
        let descriptor = FetchDescriptor<BackupOperationStorage>()
        let allItems = try context.fetch(descriptor)
        
        for item in allItems {
            context.delete(item)
        }
        
        try context.save()
    }


    private func fetch(by id: Int) throws -> BackupOperationStorage? {
        let predicate = #Predicate<BackupOperationStorage> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try context.fetch(descriptor).first
    }
    
    func get(by id: Int) async throws -> BackupOperation? {
        let predicate = #Predicate<BackupOperationStorage> { $0.id == id }
        let descriptor = FetchDescriptor<BackupOperationStorage>(predicate: predicate)
        return try context.fetch(descriptor).first?.toDomain()
    }
}

