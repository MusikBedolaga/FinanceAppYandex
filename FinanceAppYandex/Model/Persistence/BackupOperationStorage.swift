import Foundation
import SwiftData

@Model
final class BackupOperationStorage {
    @Attribute(.unique)
    var id: Int

    var operationType: String
    var transactionData: Data?
    var balanceDelta: String?
    
    

    init(id: Int, operationType: BackupOperationType, transaction: Transaction?, balanceDelta: Decimal?) {
        self.id = id
        self.operationType = operationType.rawValue
        if let transaction = transaction {
            self.transactionData = try? JSONEncoder().encode(transaction)
        }
        self.balanceDelta = balanceDelta.map { "\($0)" }
    }


    func toDomain() -> BackupOperation {
        let transaction = try? JSONDecoder().decode(Transaction.self, from: transactionData ?? Data())
        let delta = balanceDelta.flatMap { Decimal(string: $0) }
        return BackupOperation(id: id, operationType: BackupOperationType(rawValue: operationType)!, transaction: transaction, balanceDelta: delta)
    }
}

