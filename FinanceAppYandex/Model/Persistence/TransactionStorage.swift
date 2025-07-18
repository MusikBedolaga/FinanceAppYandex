import SwiftData
import Foundation

@Model
final class TransactionStorage {
    @Attribute(.unique) var id: Int
    @Attribute(originalName: "account_id") var accountId: Int
    var amount: Decimal
    @Attribute(originalName: "transaction_date") var transactionDate: Date
    @Attribute(originalName: "created_at") var createdAt: Date = Date()
    @Attribute(originalName: "updated_at") var updatedAt: Date = Date()
    
    @Relationship(deleteRule: .nullify)
    var category: CategoryStorage?
    
    @Relationship(deleteRule: .nullify)
    var bankAccount: BankAccountStorage?
    
    init(
        id: Int,
        accountId: Int,
        amount: Decimal,
        transactionDate: Date,
        category: CategoryStorage,
        bankAccount: BankAccountStorage
    ) {
        self.id = id
        self.accountId = accountId
        self.amount = amount
        self.transactionDate = transactionDate
        self.category = category
        self.bankAccount = bankAccount
    }
    
    func toDomain() -> Transaction? {
        guard let category, let bankAccount else {
            return nil
        }

        return Transaction(
            id: self.id,
            account: bankAccount.toDomain(),
            category: category.toDomain(),
            amount: self.amount,
            transactionDate: self.transactionDate,
            comment: nil,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
