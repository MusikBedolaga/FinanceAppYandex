//
//  MyHistoryView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 16.06.2025.
//

import SwiftUI

struct MyHistoryView: View {
    
    private var direction: Direction
    
    @StateObject private var viewModel: MyHistoryViewModel
    
    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: MyHistoryViewModel(for: direction))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            titleScreen
            filterView
            operationListView
            sortOptionView
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("Переход на экран аналитики")
                } label: {
                    Image(systemName: "doc")
                        .tint(.purple)
                }
            }
        }
        .onChange(of: viewModel.startDate) { _ in
            Task {
                await viewModel.fetchTransactions()
            }
        }
        .onChange(of: viewModel.endDate) { _ in
            Task {
                await viewModel.fetchTransactions()
            }
        }
        .animation(.default, value: viewModel.sortOption)
    }
    
    private var titleScreen: some View {
        Text.makeScreenTitle(titleText: "Моя история")
    }
    
    private var filterView: some View {
        VStack(spacing: 12) {
            DatePicker(
                "Начало",
                selection: Binding (
                    get: { viewModel.startDate },
                    set: { viewModel.setStartTime($0) }
                ),
                displayedComponents: [.date]
            )
            DatePicker(
                "Конец",
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.setFinishTime($0) }
                ),
                displayedComponents: [.date]
            )
            HStack {
                Text("Сумма")
                Spacer()
                Text("\(viewModel.totalAmountForDate) ₽")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
        .padding(.horizontal, 10)
    }
    
    private var operationListView: some View {
        List {
            Section(header: Text("Операции")) {
                if viewModel.transactions.isEmpty {
                    Text("Нет транзакций")
                        .foregroundColor(.black)
                        .padding(.top, 40)
                        .transition(.opacity)
                } else {
                    VStack {
                        ForEach(viewModel.transactions, id: \.id) { transaction in
                            TransactionCellView(transaction: transaction)
                                .transition(.opacity)
                        }
                    }
                    
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .cornerRadius(16)
        .shadow(radius: 1)
        .frame(maxHeight: CGFloat(viewModel.transactions.count * 160))
        .padding(.horizontal, 10)
        .animation(.easeInOut, value: viewModel.startDate)
        .animation(.easeInOut, value: viewModel.endDate)
        .animation(.easeInOut, value: viewModel.sortOption)
    }
    
    private var sortOptionView: some View  {
        Picker(
            "Сортировка",
            selection: Binding(
                get: { viewModel.sortOption },
                set: { viewModel.updateSortOption(to: $0) }
            )
        ) {
            ForEach(SortOptions.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
    }
}

#Preview {
    MyHistoryView(direction: .outcome)
}
