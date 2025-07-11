//
//  TransactionsListView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI

struct TransactionsListView: View {
    @StateObject private var viewModel = TransactionsListViewModel()
    @State private var isPresentingAddScreen = false
    @State private var isShowingHistory = false
    @State private var isEditingScreen = false
    
    private let titleText: String
    private let direction: Direction
    
    private var totalAmount: Decimal {
        viewModel.transactions.reduce(0) { $0 + $1.amount }
    }
    
    init(titleText: String, direction: Direction) {
        self.titleText = titleText
        self.direction = direction
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing, content: {
            VStack(alignment: .leading, spacing: 16) {
                titleScreen
                totalAmountView
                operationListView
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            
            AddTransactionButton(isPresented: $isPresentingAddScreen) {
                
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
                
            
            NavigationLink(destination: MyHistoryView(direction: direction), isActive: $isShowingHistory) {
                EmptyView()
            }
        })
        .task {
            await viewModel.loadTransactions(for: direction)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingHistory.toggle()
                } label: {
                    Image(systemName: "clock")
                        .tint(.purple)
                }

            }
        }
        .sheet(isPresented: $isPresentingAddScreen, onDismiss: {
            Task {
                await viewModel.loadTransactions(for: direction)
            }
        }) {
            EditTransactionView(direction: direction, transaction: nil)
        }
    }
    
    private var titleScreen: some View {
        Text.makeScreenTitle(titleText: titleText)
    }
    
    private var totalAmountView: some View {
        HStack {
            Text("Всего")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.black)
            
            Spacer()
            
            Text("\(totalAmount.formatted(.number.grouping(.automatic))) $")
        }
        .padding()
        .frame(width: 370, height: 44)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var operationListView: some View {
        List {
            Section(header: Text("Операции")) {
                if viewModel.transactions.isEmpty {
                    Text("Нет транзакций")
                        .foregroundColor(.black)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.transactions, id: \.id) { transaction in
                        NavigationLink(
                            destination: EditTransactionView(
                                direction: direction,
                                transaction: transaction
                            )
                        ) {
                            TransactionCellView(transaction: transaction)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(maxHeight: CGFloat(viewModel.transactions.count * 160))
        .padding(.horizontal, 10)
    }
}

#Preview {
    TransactionsListView(titleText: "Расходы сегодня", direction: .income)
}
