//
//  TransactionsListView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @StateObject private var viewModel: TransactionsListViewModel
    @State private var isPresentingAddScreen = false
    @State private var isShowingHistory = false
    @State private var isEditingScreen = false
    private var modelContainer: ModelContainer
    
    private let titleText: String
    private let direction: Direction
    
    private var totalAmount: Decimal {
        viewModel.transactions.reduce(0) { $0 + $1.amount }
    }
    
    init(titleText: String, direction: Direction, modelContainer: ModelContainer) {
        self.titleText = titleText
        self.direction = direction
        self.modelContainer = modelContainer
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(modelContainer: modelContainer))
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
                
            
            NavigationLink(destination: MyHistoryView(direction: direction, modelContainer: modelContainer), isActive: $isShowingHistory) {
                EmptyView()
            }
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        })
        .task {
            await viewModel.loadTransactions(for: direction)
            await viewModel.loadCurrency()
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
            EditTransactionView(direction: direction, transaction: nil, modelContainer: modelContainer)
        }
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.dismissAlert() } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(viewModel.alertMessage ?? "Неизвестная ошибка"),
                dismissButton: .default(Text("Ок")) { viewModel.dismissAlert() }
            )
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
            
            Text("\(totalAmount.formatted(.number.grouping(.automatic))) \(viewModel.currency)")
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
                                transaction: transaction, modelContainer: modelContainer
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
    let container = try! ModelContainer(for: BankAccountStorage.self, TransactionStorage.self, CategoryStorage.self, BackupOperationStorage.self)
        TabBarApp(modelContainer: container)
    TransactionsListView(titleText: "Расходы сегодня", direction: .income, modelContainer: container)
}
