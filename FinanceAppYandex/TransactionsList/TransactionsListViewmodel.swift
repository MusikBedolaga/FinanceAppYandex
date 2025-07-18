//
//  TransactionsListViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI

final class TransactionsListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []

    private let transactionsService = TransactionsService.shared
    
    func loadTransactions(for direction: Direction) async {
        let calendar = Calendar.current
        let now = Date()
            
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)

        let allForToday = await transactionsService.get(from: startOfDay, to: endOfDay)
        let filtered = allForToday.filter { $0.category.direction == direction }

        await MainActor.run {
            withAnimation(.easeInOut) {
                self.transactions = filtered
            }
        }
    }
}

