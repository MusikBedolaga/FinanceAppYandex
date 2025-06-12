//
//  TransactionsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation


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
        Category(id: 2, name: "Лечение зубов", emoji: "🦷", isIncome: false),
        Category(id: 3, name: "Продукты", emoji: "🧺", isIncome: false)
    ]
    
    private(set) var transactions: [Transaction] = []

    init() {
        let now = Date()
        transactions = [
            Transaction(
                id: 1,
                account: bankAccount,
                category: categories[0],
                amount: Decimal(250),
                transactionDate: now.addingTimeInterval(-86400 * 2),
                comment: "Стоматолог",
                createdAt: now,
                updatedAt: now
            ),
            Transaction(
                id: 2,
                account: bankAccount,
                category: categories[1],
                amount: Decimal(150),
                transactionDate: now.addingTimeInterval(-86400),
                comment: "Продукты",
                createdAt: now,
                updatedAt: now
            )
        ]
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


