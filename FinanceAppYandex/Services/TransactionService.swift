//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation

actor TransactionsService {
    private let bankAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: Decimal(1000),
        currency: "₽",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    private let categories: [Category] = [
        Category(id: 1, name: "Зарплата", emoji: "💼", isIncome: true),
        Category(id: 2, name: "Фриланс", emoji: "🧑‍💻", isIncome: true),
        Category(id: 3, name: "Лечение зубов", emoji: "🦷", isIncome: false),
        Category(id: 4, name: "Продукты", emoji: "🧺", isIncome: false),
        Category(id: 5, name: "Развлечения", emoji: "🎮", isIncome: false)
    ]
    
    private(set) var transactions: [Transaction] = []
    
    static let shared = TransactionsService()

    private init() {
        let calendar = Calendar.current
        let now = Date()
        
        transactions = [
            Transaction(
                id: 1,
                account: bankAccount,
                category: categories[0],
                amount: Decimal(100_000),
                transactionDate: calendar.date(byAdding: .day, value: -3, to: now)!,
                comment: "Зарплата за май",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 2,
                account: bankAccount,
                category: categories[1],
                amount: Decimal(25_000),
                transactionDate: calendar.date(byAdding: .day, value: -40, to: now)!,
                comment: "Проект от клиента",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 6,
                account: bankAccount,
                category: categories[1],
                amount: Decimal(5_000),
                transactionDate: now,
                comment: "Премия",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 3,
                account: bankAccount,
                category: categories[2],
                amount: Decimal(5_000),
                transactionDate: calendar.date(byAdding: .day, value: -2, to: now)!,
                comment: "Стоматолог",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 4,
                account: bankAccount,
                category: categories[3],
                amount: Decimal(1_200),
                transactionDate: calendar.date(byAdding: .day, value: -25, to: now)!,
                comment: "Магнит",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 5,
                account: bankAccount,
                category: categories[4],
                amount: Decimal(1_800),
                transactionDate: calendar.date(byAdding: .day, value: -60, to: now)!,
                comment: "Steam игры",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 7,
                account: bankAccount,
                category: categories[3],
                amount: Decimal(700),
                transactionDate: now,
                comment: "Кафе",
                createdAt: now,
                updatedAt: now
            )
        ]
    }
    
    func getAll() -> [Transaction] {
        return transactions
    }

    func get(from: Date, to: Date) async -> [Transaction] {
        return transactions.filter { $0.transactionDate >= from && $0.transactionDate <= to }
    }

    func add(_ transaction: Transaction) async {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func update(_ transaction: Transaction) async {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[index] = transaction
    }

    func delete(id: Int) async {
        transactions.removeAll { $0.id == id }
    }
    
    func getFiltered(
        direction: Direction,
        startDate: Date,
        endDate: Date,
        sortOption: SortOptions
    ) async -> [Transaction] {
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
    ) async -> Decimal {
        let filtered = transactions
            .filter { $0.transactionDate >= startDate && $0.transactionDate <= endDate }
            .filter { $0.category.direction == direction }
        return filtered.reduce(0) { $0 + $1.amount }
    }
    
    func defaultTransactionIncome() async -> Transaction {
        return Transaction(
            id: Int.random(in: 0...1000),
            account: bankAccount,
            category: categories[0],
            amount: 0,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func defaultTransactionOutcome() async -> Transaction {
        return Transaction(
            id: Int.random(in: 0...1000),
            account: bankAccount,
            category: categories[4],
            amount: 0,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
