//
//  MyAccountViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 22.06.2025.
//

import Foundation
import SwiftUI

final class MyAccountViewModel: ObservableObject {
    @Published var bankAccount: BankAccount?
    @Published var editingBalance: String = ""
    @Published var editingCurrency: String = ""
    @Published private(set) var isLoading: Bool = false
    
    private var bankAccountService = BankAccountsService()
    
    var formatedBalance: String {
        guard let account = bankAccount else { return "0 $" }
        return "\(account.balance) \(account.currency)"
    }
    
    init() {
        Task {
            let account = await bankAccountService.get()
            await MainActor.run {
                self.bankAccount = account
                self.editingBalance = String(describing: account.balance)
                self.editingCurrency = account.currency
            }
        }
    }
    
    func saveChanges() async {
        guard let account = bankAccount else { return }
        
        let updatedBanckAccount = BankAccount(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: Decimal(string: editingBalance) ?? account.balance,
            currency: editingCurrency,
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        
        await bankAccountService.update(account: updatedBanckAccount)

        await MainActor.run {
            self.bankAccount = updatedBanckAccount
        }
    }
    
    func refresh() {
        isLoading = true
        Task {
            let updatedAccount = await bankAccountService.get()
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                withAnimation {
                    self.bankAccount = updatedAccount
                    self.editingBalance = String(describing: updatedAccount.balance)
                    self.editingCurrency = updatedAccount.currency
                    self.isLoading = false
                }
            }
        }
    }
    
    func filterBalanceInput(_ input: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let filteredScalars = input.unicodeScalars.filter { allowedCharacters.contains($0) }
        var filtered = String(String.UnicodeScalarView(filteredScalars))

        var separatorCount = 0
        filtered = filtered.filter { char in
            if char == "." {
                separatorCount += 1
                return separatorCount == 1
            }
            return true
        }

        if filtered.count > 1 && filtered.first == "0" {
            let secondChar = filtered[filtered.index(after: filtered.startIndex)]
            if secondChar != "." {
                filtered = String(filtered.drop { $0 == "0" })
            }
        }

        if filtered.isEmpty {
            filtered = "0"
        }

        return filtered
    }
}
