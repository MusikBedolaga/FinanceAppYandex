//
//  BankAccountsService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 07.06.2025.
//

import Foundation

final class BankAccountsService {
    private var account: BankAccount = BankAccount(
        id: 1,
        userId: 1,
        name: "BankAccount1",
        balance: 1000,
        currency: "$",
        createdAt: Date(),
        updatedAt: Date()
    )

    func get() async -> BankAccount {
        return account
    }

    func update(account: BankAccount) async {
        self.account = account
    }
}

