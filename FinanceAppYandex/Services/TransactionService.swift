//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation
import SwiftData

//TODO: много ответсвенности на класс - разделить
actor TransactionsService {
    
    private let network: NetworkService
    private let localStorage: TransactionStorageProtocol
    private let backupStorage: TransactionBackupStorageProtocol
    private let bankAccountService: BankAccountsService
    private let bankAccountLocalStorage: SwiftDataBankAccountStorage
    private let categoryService: CategoriesService
    struct EmptyResponse: Decodable {}
    
    init(
        network: NetworkService,
        modelContainer: ModelContainer
    ) {
        self.network = network
        self.localStorage = SwiftDataTransactionStorage(modelContainer: modelContainer)
        self.backupStorage = SwiftDataTransactionBackupStorage(modelContainer: modelContainer)
        self.bankAccountLocalStorage = SwiftDataBankAccountStorage(modelContainer: modelContainer)
        self.bankAccountService = BankAccountsService(network: network, modelContainer: modelContainer)
        self.categoryService = CategoriesService(network: network, modelContainer: modelContainer)
    }
    
    
    func get(from: Date, to: Date) async throws -> [Transaction] {
        // Получаем аккаунт
        let account = try await bankAccountService.get()
        
        // Загружаем операции из бэкапа
        let backupOperations: [BackupOperation] = await {
            do {
                return try await self.backupStorage.load()
            } catch {
                print("Не удалось загрузить бэкап операций: \(error)")
                return []
            }
        }()
                
        // Синхронизируем операции с сервером
        var successfullySynced: [Transaction] = []
        
        for op in backupOperations {
            guard let transaction = op.transaction else { continue }

            do {
                switch op.operationType {
                case .add:
                    _ = try await self.add(transaction)
                case .update:
                    _ = try await self.update(transaction: transaction, fromBackupSync: true)
                case .delete:
                    _ = try await self.delete(transaction: transaction)
                }

                successfullySynced.append(transaction)
            } catch {
                print("Нету интернета, добавляем в бекап")
            }
        }
        // Удаляем синхронизированные операции
        if !successfullySynced.isEmpty {
            try await self.backupStorage.removeMany(transactions: successfullySynced)
        }
        
                
        // Запрос в сеть
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateStr = formatter.string(from: from)
        let endDateStr = formatter.string(from: to)
        let endpoint = "transactions/account/\(account.id)/period?startDate=\(startDateStr)&endDate=\(endDateStr)"
        
        do {
            let remoteTransactions: [Transaction] = try await network.request(endpoint: endpoint)
            // Сохраняем в локалку
            await withTaskGroup(of: Void.self) { group in
                for transaction in remoteTransactions {
                    group.addTask {
                        try? await self.localStorage.remove(by: transaction.id)
                        try? await self.localStorage.add(transaction)
                    }
                }
            }
            
            // костыль для операций удаления
            try await backupStorage.clearAll()
            
            return remoteTransactions.filter {
                $0.transactionDate >= from && $0.transactionDate <= to
            }
        } catch {
            // загружаем локалу и бэкап
            let localTransactions = try await self.localStorage.load()
            let backupTransactions = (try await self.backupStorage.load()).filter {
                $0.operationType != .delete
            }
            
            print(localTransactions)
            print("\n")
            print(backupTransactions)
            
            let transactions = localTransactions + backupTransactions.compactMap { $0.transaction }
            return transactions
                .filter { $0.transactionDate >= from && $0.transactionDate <= to }
                .uniqueById()
        }
    }


    
    func getById(by id: Int) async throws -> Transaction {
        try await network.request(endpoint: "/transactions/\(id)")
    }

    func add(_ transaction: Transaction) async throws -> Transaction {
        let request = TransactionRequest(
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: "\(transaction.amount)",
            transactionDate: ISO8601DateFormatter().string(from: transaction.transactionDate),
            comment: transaction.comment
        )
        let delta = computeBalanceDelta(for: transaction)

        do {
            let response: TransactionResponse = try await network.request(
                endpoint: "transactions",
                method: "POST",
                body: request
            )

            var account = transaction.account
            account.balance += delta

            let category = try await categoryService.getById(by: response.categoryId)
            let resultTransaction = Transaction(from: response, account: account, category: category)

            try await localStorage.add(resultTransaction)
            _ = try await bankAccountService.update(account)

            try? await backupStorage.remove(by: transaction.id)

            return resultTransaction
        } catch {
            let alreadyExists = try await backupStorage.get(by: transaction.id) != nil

            if !alreadyExists {
                let operation = BackupOperation(
                    id: transaction.id,
                    operationType: .add,
                    transaction: transaction,
                    balanceDelta: delta
                )
                try await backupStorage.addOrUpdate(operation)

                var account = transaction.account
                account.balance += delta
                _ = try await bankAccountService.update(account)
            }

            throw error
        }
    }

    func update(transaction: Transaction, fromBackupSync: Bool = false) async throws -> Transaction {
        let oldTransaction: Transaction? = try? await localStorage.get(by: transaction.id)
        let oldDelta = oldTransaction.map { computeBalanceDelta(for: $0) } ?? 0

        let transactionRequest = TransactionRequest(from: transaction)

        do {
            let result: Transaction = try await network.request(
                endpoint: "transactions/\(transaction.id)",
                method: "PUT",
                body: transactionRequest
            )

            try await localStorage.update(transaction)

            let newDelta = computeBalanceDelta(for: transaction)
            let delta = newDelta - oldDelta

            if !fromBackupSync {
                var account = transaction.account
                account.balance += delta
                _ = try await bankAccountService.update(account)
            }

            try? await backupStorage.remove(by: transaction.id)

            return result
        } catch {
            let newDelta = computeBalanceDelta(for: transaction)
            let delta = newDelta - oldDelta

            let alreadyExists = try await backupStorage.get(by: transaction.id) != nil

            if !alreadyExists {
                let operation = BackupOperation(
                    id: transaction.id,
                    operationType: .update,
                    transaction: transaction,
                    balanceDelta: delta
                )
                try await backupStorage.addOrUpdate(operation)

                try await localStorage.update(transaction)

                var account = transaction.account
                account.balance += delta
                _ = try await bankAccountService.update(account)
            }

            throw error
        }
    }


    func delete(transaction: Transaction) async throws {
        let delta = -computeBalanceDelta(for: transaction)

        do {
            let _: EmptyResponse = try await network.request(
                endpoint: "transactions/\(transaction.id)",
                method: "DELETE"
            )

            try await localStorage.remove(by: transaction.id)

            var account = transaction.account
            account.balance += delta
            _ = try await bankAccountService.update(account)

            try? await backupStorage.remove(by: transaction.id)

            print("Удаление прошло успешно")

        } catch let error as NetworkClientError {
            switch error {
            case .emptyBodyExpectedNonEmptyResponse:
                try? await localStorage.remove(by: transaction.id)

                var account = transaction.account
                account.balance += delta
                _ = try await bankAccountService.update(account)

                try? await backupStorage.remove(by: transaction.id)

            default:
                // 💣 Удаление не удалось — оффлайн сценарий
                let alreadyExists = try await backupStorage.get(by: transaction.id) != nil

                if !alreadyExists {
                    let operation = BackupOperation(
                        id: transaction.id,
                        operationType: .delete,
                        transaction: transaction,
                        balanceDelta: delta
                    )
                    try await backupStorage.addOrUpdate(operation)

                    try await localStorage.remove(by: transaction.id)
                    var account = transaction.account
                    account.balance += delta
                    _ = try await bankAccountService.update(account)
                } else {
                    print("Операция удаления уже в бэкапе, пропускаем")
                }

                throw error
            }
        }
    }

    
    func getFiltered(
        direction: Direction,
        startDate: Date,
        endDate: Date,
        sortOption: SortOptions
    ) async throws -> [Transaction] {
        let transactions = try await self.get(from: startDate, to: endDate)
        let filtered = transactions
            .filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
            .filter { $0.category.direction == direction }
            
        switch sortOption {
        case .date:
            return filtered.sorted { $0.transactionDate < $1.transactionDate }
        case .amount:
            return filtered.sorted { $0.amount < $1.amount }
        case .none:
            return filtered
        }
    }

    func totalAmount(
        direction: Direction,
        startDate: Date,
        endDate: Date
    ) async throws -> Decimal {
        let transactions = try await self.get(from: startDate, to: endDate)
        let filtered = transactions
            .filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
            .filter { $0.category.direction == direction }
        return filtered.reduce(0) { $0 + $1.amount }
    }
    
    
    func defaultTransactionIncome() async throws -> Transaction {
        let account = await getAnyAccount()
        let category = Category(id: 1, name: "Зарплата", emoji: "💼", isIncome: true)
        
        return Transaction(
            id: Int.random(in: 1000...9999),
            account: account,
            category: category,
            amount: 0,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    func defaultTransactionOutcome() async throws -> Transaction {
        let account = await getAnyAccount()
        let category = Category(id: 4, name: "Продукты", emoji: "🧺", isIncome: false)
        
        return Transaction(
            id: Int.random(in: 1000...9999),
            account: account,
            category: category,
            amount: 0,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    private func getAnyAccount() async -> BankAccount {
        if let online = try? await bankAccountService.get() {
            return online
        }
        if let local = try? await bankAccountLocalStorage.getAny() {
            return local
        }
        return BankAccount(
            id: -1,
            userId: -1,
            name: "Неизвестный",
            balance: 0,
            currency: "$",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    
    private func computeBalanceDelta(for transaction: Transaction) -> Decimal {
        return transaction.category.isIncome ? transaction.amount : -transaction.amount
    }
    
    
}

struct EmptyResponse: Decodable {}
