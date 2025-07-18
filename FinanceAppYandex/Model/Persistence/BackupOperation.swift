import Foundation

enum BackupOperationType: String, Codable {
    case add, update, delete
}

struct BackupOperation: Codable, Identifiable {
    var id: Int // id транзакции
    var operationType: BackupOperationType
    var transaction: Transaction?
    var balanceDelta: Decimal?
}
