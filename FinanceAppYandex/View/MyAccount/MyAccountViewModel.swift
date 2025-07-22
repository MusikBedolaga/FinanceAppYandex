//
//  MyAccountViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 22.06.2025.
//

import Foundation
import SwiftUI
import SwiftData

enum ChartRange: String, CaseIterable {
    case daily = "Дни"
    case monthly = "Месяцы"
}


@MainActor
final class MyAccountViewModel: ObservableObject {
    @Published var bankAccount: BankAccount?
    @Published var editingBalance: String = ""
    @Published var editingCurrency: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    @Published var balanceStatistics: [Date: Decimal] = [:]
    @Published var selectedRange: ChartRange = .daily
    @Published var monthlyBalanceStatistics: [Date: Decimal] = [:]

    private var bankAccountService: BankAccountsService?
    private var modelContainer: ModelContainer
    private var transactionsService: TransactionsService?
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    var formatedBalance: String {
        guard let account = bankAccount else { return "0 $" }
        return "\(account.balance) \(account.currencySymbol)"
    }
    
    func loadBankAccount() async {
        if bankAccountService == nil {
            guard
                let baseURL = APIKeysStorage.shared.getBaseURL(),
                let token = APIKeysStorage.shared.getToken()
            else {
                self.alertMessage = "Нет данных для подключения к API"
                return
            }
            let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
            self.bankAccountService = BankAccountsService(network: network, modelContainer: modelContainer)
        }
        
        isLoading = true
        defer { isLoading = false }
                
        guard let bankAccountService else {
            alertMessage = "Service not initialized"
            return
        }
        
        do {
            let account = try await bankAccountService.get()
            
            await MainActor.run {
                self.bankAccount = account
                self.editingBalance = String(describing: account.balance)
                self.editingCurrency = account.currencySymbol
            }
            
            await calculateStatisticsForAccounts()
        } catch {
            self.alertMessage = error.localizedDescription
            return
        }
    }
    
    func refresh() {
        Task {
            isLoading = true
            defer { isLoading = false }

            guard let bankAccountService = bankAccountService else { return }
            do {
                var updatedAccount = try await bankAccountService.get()
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
                guard let newBalance = Decimal(string: self.editingBalance) else {
                    throw NSError(domain: "InvalidBalanceFormat", code: 0)
                }
                updatedAccount.balance = newBalance
                switch self.editingCurrency {
                case "$": updatedAccount.currency = "USD"
                case "€": updatedAccount.currency = "RUB"
                case "₽": updatedAccount.currency = "EUR"
                default:
                    break
                }
                
                _ = try await bankAccountService.update(updatedAccount)
                
                await MainActor.run {
                    withAnimation {
                        self.bankAccount = updatedAccount
                        self.editingBalance = String(describing: updatedAccount.balance)
                        self.editingCurrency = updatedAccount.currencySymbol
                    }
                }
                
            } catch {
                self.alertMessage = error.localizedDescription
            }
        }
    }

    func saveChanges() async {
        isLoading = true
        defer { isLoading = false }
        guard let bankAccountService = bankAccountService else { return }
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
        do {
            self.bankAccount = try await bankAccountService.update(updatedBanckAccount)
        } catch {
            self.alertMessage = error.localizedDescription
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
    
    func calculateStatisticsForAccounts() async {
        if transactionsService == nil {
            guard
                let baseURL = APIKeysStorage.shared.getBaseURL(),
                let token = APIKeysStorage.shared.getToken()
            else {
                self.alertMessage = "Нет данных для подключения к API"
                return
            }
            let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
            self.transactionsService = TransactionsService(network: network, modelContainer: modelContainer)
        }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let transactionsService, let currentBalance = bankAccount?.balance else {
            alertMessage = "Сервис или баланс счёта не инициализирован"
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -29, to: today) else {
            alertMessage = "Не удалось вычислить начальную дату"
            return
        }
        
        do {
            let transactions = try await transactionsService.get(from: startDate, to: today)
            
            let parsedTransactions: [(date: Date, amount: Decimal)] = transactions.map {
                (calendar.startOfDay(for: $0.transactionDate), $0.amount)
            }
            
            var transactionsByDate: [Date: [Decimal]] = [:]
            for t in parsedTransactions {
                transactionsByDate[t.date, default: []].append(t.amount)
            }
            
            var balanceStats: [Date: Decimal] = [:]
            var runningBalance = currentBalance
            
            for offset in (0..<30).reversed() {
                guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                
                balanceStats[day] = runningBalance
                
                let transactionsForDay = transactionsByDate[day] ?? []
                let totalForDay = transactionsForDay.reduce(Decimal(0), +)
                runningBalance -= totalForDay
            }
            
            await MainActor.run {
                self.balanceStatistics = balanceStats
            }

        } catch {
            self.alertMessage = "Ошибка при загрузке транзакций: \(error.localizedDescription)"
        }
    }

    func calculateMonthlyStatistics() async {
        guard let transactionsService, let currentBalance = bankAccount?.balance else {
            alertMessage = "Сервис или баланс счёта не инициализирован"
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .month, value: -23, to: today) else {
            alertMessage = "Не удалось вычислить начальную дату"
            return
        }

        do {
            let transactions = try await transactionsService.get(from: startDate, to: today)

            let parsedTransactions: [(date: Date, amount: Decimal)] = transactions.map {
                let components = calendar.dateComponents([.year, .month], from: $0.transactionDate)
                let monthStart = calendar.date(from: components)!
                return (monthStart, $0.amount)
            }

            var transactionsByMonth: [Date: [Decimal]] = [:]
            for t in parsedTransactions {
                transactionsByMonth[t.date, default: []].append(t.amount)
            }

            var stats: [Date: Decimal] = [:]
            var runningBalance = currentBalance

            for offset in (0..<24).reversed() {
                guard let month = calendar.date(byAdding: .month, value: -offset, to: today),
                      let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
                else { continue }

                stats[startOfMonth] = runningBalance
                let transactionsForMonth = transactionsByMonth[startOfMonth] ?? []
                let totalForMonth = transactionsForMonth.reduce(Decimal(0), +)
                runningBalance -= totalForMonth
            }

            await MainActor.run {
                self.monthlyBalanceStatistics = stats
            }

        } catch {
            alertMessage = "Ошибка при загрузке транзакций: \(error.localizedDescription)"
        }
    }

    
    func dismissAlert() {
        alertMessage = nil
    }
}
