//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation

//TODO: Сделать actor
final class TransactionsService {
    private var bankAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счёт",
        balance: Decimal(1000),
        currency: "₽",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    private var categories: [Category] = [
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
                amount: Decimal(100000),
                transactionDate: calendar.date(byAdding: .day, value: -3, to: now)!,
                comment: "Зарплата за май",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 2,
                account: bankAccount,
                category: categories[1],
                amount: Decimal(25000),
                transactionDate: calendar.date(byAdding: .day, value: -40, to: now)!,
                comment: "Проект от клиента",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 6,
                account: bankAccount,
                category: categories[1],
                amount: Decimal(5000),
                transactionDate: now,
                comment: "Премия",
                createdAt: now,
                updatedAt: now
            ),
            
            Transaction(
                id: 3,
                account: bankAccount,
                category: categories[2],
                amount: Decimal(5000),
                transactionDate: calendar.date(byAdding: .day, value: -2, to: now)!,
                comment: "Стоматолог",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 4,
                account: bankAccount,
                category: categories[3],
                amount: Decimal(1200),
                transactionDate: calendar.date(byAdding: .day, value: -25, to: now)!,
                comment: "Магнит",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 5,
                account: bankAccount,
                category: categories[4],
                amount: Decimal(1800),
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
}



extension TransactionsService {
    func defaultTransactionIncome() -> Transaction {
        return Transaction(
            id: Int.random(in: 0...1000),
            account: bankAccount,
            category: categories[0],
            amount: 0,
            transactionDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func defaultTransactionOutcome() -> Transaction {
        return Transaction(
            id: Int.random(in: 0...1000),
            account: bankAccount,
            category: categories[4],
            amount: 0,
            transactionDate: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
