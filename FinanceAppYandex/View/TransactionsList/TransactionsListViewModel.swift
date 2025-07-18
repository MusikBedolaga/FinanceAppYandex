//
//  TransactionsListViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class TransactionsListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    @Published var currency: String = " "

    private var transactionsService: TransactionsService?
    private var bankAccountService: BankAccountsService?
    private var modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func loadTransactions(for direction: Direction) async {
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
        
        guard let transactionsService else {
            alertMessage = "Service not initialized"
            transactions = []
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
        
        do {
            let allForToday = try await transactionsService.get(from: startOfDay, to: endOfDay)
            let filtered = allForToday.filter { $0.category.direction == direction }

            withAnimation(.easeInOut) {
                self.transactions = filtered
            }
        } catch {
            alertMessage = error.localizedDescription
        }
    }
    
    func loadCurrency() async {
        if bankAccountService == nil {
            guard
                let baseURL = APIKeysStorage.shared.getBaseURL(),
                let token = APIKeysStorage.shared.getToken()
            else {
                return
            }
            let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
            self.bankAccountService = BankAccountsService(network: network, modelContainer: modelContainer)
        }

        guard let bankAccountService else { return }

        do {
            let account = try await bankAccountService.get()
            await MainActor.run {
                self.currency = account.currencySymbol
            }
        } catch {
            alertMessage = "Ошибка при получении валюты"
            return
        }
    }

    
    func dismissAlert() {
        alertMessage = nil
    }
}



