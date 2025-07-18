//
//  Transaction.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


struct Transaction: Codable {
    var id: Int
    var account: BankAccount
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date?
    var updatedAt: Date?

    private enum CodingKeys: String, CodingKey {
        case id, account, category, amount, transactionDate, comment, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        account = try container.decode(BankAccount.self, forKey: .account)
        category = try container.decode(Category.self, forKey: .category)
        comment = try? container.decodeIfPresent(String.self, forKey: .comment)
        transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        createdAt = try? container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try? container.decodeIfPresent(Date.self, forKey: .updatedAt)

        if let amountString = try? container.decode(String.self, forKey: .amount),
           let amountDecimal = Decimal(string: amountString) {
            amount = amountDecimal
        } else if let amountDouble = try? container.decode(Double.self, forKey: .amount) {
            amount = Decimal(amountDouble)
        } else {
            amount = 0
        }
    }

    init(
        id: Int,
        account: BankAccount,
        category: Category,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}



extension Transaction {
    init(
        from response: TransactionResponse,
        account: BankAccount,
        category: Category
    ) {
        self.id = response.id
        self.account = account
        self.category = category
        self.amount = Decimal(string: response.amount) ?? 0
        self.transactionDate = ISO8601DateFormatter().date(from: response.transactionDate) ?? Date()
        self.comment = response.comment
        self.createdAt = ISO8601DateFormatter().date(from: response.createdAt)
        self.updatedAt = ISO8601DateFormatter().date(from: response.updatedAt)
    }
}

extension Transaction {
    static func createDefault(direction: Direction) -> Transaction {
        let category = Category(
            id: direction == .income ? 1 : 4,
            name: direction == .income ? "Зарплата" : "Продукты",
            emoji: direction == .income ? "💼" : "🧺",
            isIncome: direction == .income
        )
        
        return Transaction(
            id: Int.random(in: 1000...9999),
            account: BankAccount(id: 1, userId: 1, name: "Основной", balance: 0, currency: "₽", createdAt: Date(), updatedAt: Date()),
            category: category,
            amount: 0,
            transactionDate: Date(),
            comment: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
