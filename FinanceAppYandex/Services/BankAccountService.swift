import Foundation
import SwiftData

actor BankAccountsService {
    private let network: NetworkService
    private let storage: BankAccountStorageProtocol
    private(set) var account: BankAccount?
    
    init(network: NetworkService, modelContainer: ModelContainer) {
        self.network = network
        self.storage = SwiftDataBankAccountStorage(modelContainer: modelContainer)
    }

    func get() async throws -> BankAccount {
        do {
            let accounts: [BankAccount] = try await network.request(endpoint: "accounts")
            
            guard let account = accounts.first else {
                throw NetworkClientError.missingData
            }
            
            if let localAccount = try await storage.getAny() {
                self.account = try await self.update(localAccount)
            } else {
                print("Локальный аккаунт не найден — создаём новый")
                try await storage.addAccount(account)
                self.account = account
            }
            
            return account
        } catch {
            let localAccount = try await storage.getAny()
            
            guard let account = localAccount else { throw NetworkClientError.missingData }
            self.account = localAccount
            
            return account
        }
    }
    
    func getById(_ id: Int) async throws -> BankAccount {
        _ = try await get()
        guard let account = account else {
            throw NSError(domain: "BankAccount", code: 404, userInfo: [NSLocalizedDescriptionKey: "Аккаунт с id \(id) не найден"])
        }
        return account
    }


    func update(_ account: BankAccount) async throws -> BankAccount {
        do {
            let safeName = account.name.isEmpty ? "Основной счет" : account.name
            
            let body = AccountCreateRequest(
                name: safeName,
                balance: "\(account.balance)",
                currency: symbolToCurrencyCode(account.currency)
            )

            let updated: BankAccount = try await network.request(
                endpoint: "accounts/\(account.id)",
                method: "PUT",
                body: body
            )
            
            try await storage.updateAccount(updated)
            
            self.account = updated
            return updated
        } catch {
            try await storage.updateAccount(account)
            self.account = account
            return account
        }
    }

    private func symbolToCurrencyCode(_ symbol: String) -> String {
        switch symbol {
        case "$": return "USD"
        case "₽": return "RUB"
        case "€": return "EUR"
        default:  return symbol
        }
    }
}
