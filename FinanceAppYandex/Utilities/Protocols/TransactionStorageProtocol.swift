import Foundation

protocol TransactionStorageProtocol: Sendable {
    func load() async throws -> [Transaction]
    func remove(by id: Int) async throws
    func update(_ transaction: Transaction) async throws
    func add(_ transaction: Transaction) async throws
    func get(by id: Int) async throws -> Transaction
}

