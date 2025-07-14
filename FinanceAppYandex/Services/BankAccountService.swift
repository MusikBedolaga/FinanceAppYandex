//
//  BankAccountsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation

actor BankAccountsService {
    private let network: NetworkService
    private(set) var account: BankAccount?

    init(network: NetworkService) {
        self.network = network
    }

    func get() async throws -> BankAccount {
        let accounts: [BankAccount] = try await network.request(endpoint: "accounts")
        guard let account = accounts.first else {
            throw NetworkClientError.missingData
        }
        self.account = account
        return account
    }

    func update(_ account: BankAccount) async throws -> BankAccount {
        let safeName = account.name.isEmpty ? "Основной счет" : account.name
        
        let body = AccountCreateRequest(
            name: safeName,
            balance: "\(account.balance)",
            currency: symbolToCurrencyCode(account.currency)
        )
        
        
        return try await network.request(
            endpoint: "accounts/\(account.id)",
            method: "PUT",
            body: body
        )
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


