//
//  BankAccount.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


struct BankAccount: Codable {
    var id: Int
    var userId: Int?
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date?
    var updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id, userId, name, balance, currency, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try? container.decodeIfPresent(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        currency = try container.decode(String.self, forKey: .currency)
        createdAt = try? container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try? container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        if let balanceString = try? container.decode(String.self, forKey: .balance),
           let balanceDecimal = Decimal(string: balanceString) {
            balance = balanceDecimal
        } else if let balanceDouble = try? container.decode(Double.self, forKey: .balance) {
            balance = Decimal(balanceDouble)
        } else {
            balance = 0
        }
    }
    
    init(
        id: Int,
        userId: Int?,
        name: String,
        balance: Decimal,
        currency: String,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
}}


extension BankAccount {
    var currencySymbol: String {
        switch currency.uppercased() {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return currency
        }
    }
}

extension BankAccount {
    func toStorage() -> BankAccountStorage {
        BankAccountStorage(
            id: self.id,
            userId: self.userId,
            name: self.name,
            balance: self.balance,
            currency: self.currency
        )
    }
}
