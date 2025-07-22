import Foundation

protocol BankAccountStorageProtocol: Sendable {
    func getAccount(by id: Int) async throws -> BankAccount?
    func updateAccount(_ account: BankAccount) async throws
    func addAccount(_ account: BankAccount) async throws
    func getAny() async throws -> BankAccount?
}
