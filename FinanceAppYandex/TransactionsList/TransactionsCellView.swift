//
//  TransactionsCellView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import SwiftUI

struct TransactionCellView: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(spacing: 0) {
            switch (transaction.category.direction) {
            case .income: IncomeCell
            case .outcome: OutcomeCell
        }
            
        Divider()
            .padding(.leading, 64)
        }
        .background(Color.white)
    }
    
    private var OutcomeCell: some View {
        HStack(spacing: 12) {
            emojiView
            categoryNameView
            Spacer()
            amountView
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private var IncomeCell: some View {
        HStack(spacing: 12) {
            categoryNameView
            Spacer()
            amountView
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    private var emojiView: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 36, height: 36)
            
            Text(transaction.category.emoji.description)
                .font(.title2)
        }
    }
    
    private var categoryNameView: some View {
        Text(transaction.category.name)
            .font(.system(size: 17))
            .foregroundColor(.black)
    }
    
    private var amountView: some View {
        HStack(spacing: 4) {
            Text(transaction.amount.description)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
            
            Text(transaction.account.currency)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.black)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 13, weight: .semibold))
        }
    }
}

#Preview {
    let mockTransaction = Transaction(
        id: 2,
        account: BankAccount(
            id: 1,
            userId: 1,
            name: "Основной счёт",
            balance: 1_000_000,
            currency: "₽",
            createdAt: Date(),
            updatedAt: Date()
        ),
        category: Category(
            id: 2,
            name: "Аренда квартиры",
            emoji: "🏠",
            isIncome: false
        ),
        amount: 100_000,
        transactionDate: Date(),
        comment: nil,
        createdAt: Date(),
        updatedAt: Date()
    )

    return TransactionCellView(transaction: mockTransaction)
        .previewLayout(.sizeThatFits)
        .background(Color(UIColor.systemGroupedBackground))
}




