import Foundation
import SwiftData

enum BankAccountError: Error {
    case notFound
    case duplicate
}

actor SwiftDataBankAccountStorage {
    private let context: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.context = ModelContext(modelContainer)
        self.context.autosaveEnabled = false
    }
}

extension SwiftDataBankAccountStorage: BankAccountStorageProtocol {
    func getAccount(by id: Int) async throws -> BankAccount? {
        let predicate = #Predicate<BankAccountStorage> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try context.fetch(descriptor).first?.toDomain()
    }
    
    
    func updateAccount(_ account: BankAccount) async throws {
        let predicate = #Predicate<BankAccountStorage> { $0.id == account.id }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let existing = try context.fetch(descriptor).first {
            // Обновляем свойства напрямую
            existing.balance = account.balance
            existing.name = account.name
            existing.currency = account.currency
            existing.updatedAt = Date()
            
            try context.save()
        } else {
            throw BankAccountError.notFound
        }
    }
    
    func addAccount(_ account: BankAccount) async throws {
        let predicate = #Predicate<BankAccountStorage> { $0.id == account.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        let existing = try context.fetch(descriptor).first
        if existing != nil {
            throw BankAccountError.duplicate
        }
        
        let newAccount = BankAccountStorage(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
        context.insert(newAccount)
        try context.save()
        
        print("✅ Аккаунт добавлен: \(account.name) — \(account.balance) \(account.currency)")
    }

    
    func getAny() async throws -> BankAccount? {
        let descriptor = FetchDescriptor<BankAccountStorage>()
        return try context.fetch(descriptor).first?.toDomain()
    }

}
