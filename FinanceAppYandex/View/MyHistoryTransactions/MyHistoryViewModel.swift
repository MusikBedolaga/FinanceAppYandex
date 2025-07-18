//
//  MyHistoryViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 16.06.2025.
//

import Foundation
import SwiftData

enum SortOptions: String, CaseIterable, Identifiable {
    case date = "По дате"
    case amount = "По сумме"
    case none = "Без сортировки"
    
    var id: String { self.rawValue }
}

@MainActor
final class MyHistoryViewModel: ObservableObject {
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var totalAmountForDate: Decimal = 0
    @Published var transactions: [Transaction] = []
    @Published var sortOption: SortOptions = .none
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    
    private var transactionsService: TransactionsService?
    private var modelContainer: ModelContainer
    private var direction: Direction
    private var originalTransactions: [Transaction] = []

    init(for direction: Direction, modelContainer: ModelContainer) {
        self.direction = direction
        let (start, end) = Self.getDefaultTime()
        self.startDate = start
        self.endDate = end
        self.modelContainer = modelContainer
    }
    
    func fetchTransactions() async {
        
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
        
        do {
            let allTransactionForDate = try await transactionsService.get(from: startDate, to: endDate)
            let filtered = allTransactionForDate.filter { $0.category.direction == self.direction }
            self.originalTransactions = filtered
            self.transactions = filtered
            setOption(sortOption)
            calculateTotalAmountForDate()
        } catch {
            print("Ошибка при получении транзакций:", error)
            if let decodingError = error as? DecodingError {
                print("Decoding error: \(decodingError)")
            }
            self.alertMessage = error.localizedDescription
            self.transactions = []
            return
        }
        
        
    }
    
    func setStartTime(_ date: Date) {
        startDate = date
        if startDate > endDate {
            endDate = startDate
        }
        Task {
            await fetchTransactions()
        }
    }
    
    func setFinishTime(_ date: Date) {
        endDate = date
        if endDate < startDate {
            endDate = startDate
        }
        Task {
            await fetchTransactions()
        }
    }
    
    private func calculateTotalAmountForDate() {
        totalAmountForDate = transactions.reduce(0) { $0 + $1.amount}
    }

    private static func getDefaultTime() -> (Date, Date) {
        let now = Date()
        let calendar = Calendar.current
        let defaultEnd = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: now)!
        let defaultStart = calendar.date(byAdding: .day, value: -30, to: defaultEnd)!
            .settingTime(hour: 0, minute: 0)!
        return (defaultStart, defaultEnd)
    }
    
    func updateSortOption(to option: SortOptions) {
        sortOption = option
        setOption(option)
    }
    
    private func setOption(_ sortOption: SortOptions) {
        switch (sortOption) {
        case .date:
            transactions.sort { $0.transactionDate < $1.transactionDate}
        case .amount:
            transactions.sort { $0.amount < $1.amount}
        case .none:
            transactions = originalTransactions
        }
    }
    
    func dismissAlert() {
        alertMessage = nil
    }
}

