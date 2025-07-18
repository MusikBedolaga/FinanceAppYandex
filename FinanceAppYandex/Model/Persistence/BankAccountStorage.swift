import Foundation
import SwiftData

@Model
final class BankAccountStorage {
    @Attribute(.unique) var id: Int
    @Attribute(originalName: "user_id") var userId: Int?
    var name: String
    var balance: Decimal
    var currency: String
    @Attribute(originalName: "create_at") var createdAt = Date()
    @Attribute(originalName: "updated_at") var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \TransactionStorage.bankAccount)
    var transactions: [TransactionStorage] = []
    
    init(id: Int, userId: Int? = nil, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
    }
    
    func toDomain() -> BankAccount {
        BankAccount(
            id: self.id,
            userId: self.userId,
            name: self.name,
            balance: self.balance,
            currency: self.currency,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension BankAccountStorage {
    convenience init(from account: BankAccount) {
        self.init(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
    }
}

