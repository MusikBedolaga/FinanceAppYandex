//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation

actor TransactionsService {
    
    
    private lazy var bankAccountService: BankAccountsService = {
        BankAccountsService(network: self.network)
    }()
    private let network: NetworkService
    
    init(network: NetworkService) {
        self.network = network
    }
    
    struct EmptyResponse: Decodable {}
    
    func getAll() async throws -> [Transaction] {
        try await network.request(endpoint: "transactions")
    }

    func get(from: Date, to: Date) async throws -> [Transaction] {
        let account = try await bankAccountService.get()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateStr = formatter.string(from: from)
        let endDateStr = formatter.string(from: to)
        let endpoint = "transactions/account/\(account.id)/period?startDate=\(startDateStr)&endDate=\(endDateStr)"
        
        return try await network.request(endpoint: endpoint)
    }

    
    func getById(by id: Int) async throws -> Transaction {
        try await network.request(endpoint: "/transactions/\(id)")
    }

    func add(_ transaction: TransactionRequest) async throws -> Transaction {
        print(transaction.categoryId)
        return try await network.request(
            endpoint: "transactions",
            method: "POST",
            body: transaction
        )
    }

    func update(id: Int, with transaction: TransactionRequest) async throws -> Transaction {
        try await network.request(
            endpoint: "transactions/\(id)",
            method: "PUT",
            body: transaction
        )
    }

    func delete(id: Int) async throws {
        _ = try await network.request(endpoint: "transactions/\(id)", method: "DELETE") as EmptyResponse
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
        let account: BankAccount = try await bankAccountService.get() ?? BankAccount(
            id: 1, userId: 1, name: "Счет", balance: 0, currency: "₽", createdAt: Date(), updatedAt: Date()
        )
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
        let account: BankAccount = try await bankAccountService.get() ?? BankAccount(
            id: 1, userId: 1, name: "Счет", balance: 0, currency: "₽", createdAt: Date(), updatedAt: Date()
        )
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
}

struct EmptyResponse: Decodable {}
