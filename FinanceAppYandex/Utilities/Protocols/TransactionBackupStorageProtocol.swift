import Foundation

protocol TransactionBackupStorageProtocol: Sendable {
    func load() async throws -> [BackupOperation]
    func addOrUpdate(_ operation: BackupOperation) async throws
    func remove(by id: Int) async throws
    func removeMany(transactions: [Transaction]) async throws
    func clearAll() async throws
    func get(by id: Int) async throws -> BackupOperation?
}
