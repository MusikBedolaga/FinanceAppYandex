import Foundation
import SwiftData

enum TransactionError: Error {
    case notFound
    case invalidData
    case storageError(Error)
    case duplicate
}

actor SwiftDataTransactionStorage {
    private let context: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.context = ModelContext(modelContainer)
        self.context.autosaveEnabled = false
    }
}

extension SwiftDataTransactionStorage: TransactionStorageProtocol {
    
    func load() async throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionStorage>(
            sortBy: [SortDescriptor(\.transactionDate, order: .reverse)]
        )
        
        let storageItems = try context.fetch(descriptor)
        return storageItems.compactMap { $0.toDomain() }
    }

    func add(_ transaction: Transaction) async throws {
        if try fetchTransaction(by: transaction.id) != nil {
            throw TransactionError.duplicate
        }

        let bankAccountStorage = try fetchOrCreateBankAccount(for: transaction.account)
        let categoryStorage = try fetchOrCreateCategory(for: transaction.category)

        let storage = TransactionStorage(
            id: transaction.id,
            accountId: transaction.account.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            category: categoryStorage,
            bankAccount: bankAccountStorage
        )
        
        context.insert(storage)
        try context.save()
    }

    func update(_ transaction: Transaction) async throws {
        guard let existing = try fetchTransaction(by: transaction.id) else {
            throw TransactionError.notFound
        }

        if existing.category?.id != transaction.category.id {
            existing.bankAccount = try fetchOrCreateBankAccount(for: transaction.account)
        }
        
        if existing.category?.id != transaction.category.id {
            existing.category = try fetchOrCreateCategory(for: transaction.category)
        }

        existing.accountId = transaction.account.id
        existing.amount = transaction.amount
        existing.transactionDate = transaction.transactionDate
        existing.updatedAt = Date()

        try context.save()
    }

    func remove(by id: Int) async throws {
        guard let transaction = try fetchTransaction(by: id) else {
            throw TransactionError.notFound
        }

        context.delete(transaction)
        try context.save()
    }

    private func fetchTransaction(by id: Int) throws -> TransactionStorage? {
        let predicate = #Predicate<TransactionStorage> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try context.fetch(descriptor).first
    }
    
    private func fetchOrCreateBankAccount(for account: BankAccount) throws -> BankAccountStorage {
        let predicate = #Predicate<BankAccountStorage> { $0.id == account.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let storage = BankAccountStorage(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
        context.insert(storage)
        return storage
    }
    
    private func fetchOrCreateCategory(for category: Category) throws -> CategoryStorage {
        let predicate = #Predicate<CategoryStorage> { $0.id == category.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let storage = CategoryStorage(
            id: category.id,
            emoji: category.emoji,
            name: category.name,
            isIncome: category.isIncome
        )
        context.insert(storage)
        return storage
    }
    
    func get(by id: Int) async throws -> Transaction {
        guard let storage = try fetchTransaction(by: id),
              let transaction = storage.toDomain() else {
            throw TransactionError.notFound
        }
        return transaction
    }
}
