import SwiftUI
import SwiftData

struct MyHistoryView: View {
    
    private var direction: Direction
    private var modelContainer: ModelContainer
    
    @StateObject private var viewModel: MyHistoryViewModel
    @State private var showAnalysis = false
    
    init(direction: Direction, modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.direction = direction
        _viewModel = StateObject(wrappedValue: MyHistoryViewModel(for: direction, modelContainer: modelContainer))
    }
    
    var body: some View {
        ZStack {
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
                        showAnalysis = true
                    } label: {
                        Image(systemName: "doc")
                            .tint(.purple)
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: AnalysisView(direction: self.direction, modelContainer: modelContainer),
                    isActive: $showAnalysis,
                    label: { EmptyView() }
                )
                .hidden()
            )
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
            .task {
                await viewModel.fetchTransactions()
            }
            .alert(
                isPresented: Binding<Bool>(
                    get: { viewModel.alertMessage != nil },
                    set: { if !$0 { viewModel.dismissAlert() } }
                )
            ) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(viewModel.alertMessage ?? "Неизвестная ошибка"),
                    dismissButton: .default(Text("Ок")) { viewModel.dismissAlert() }
                )
            }
            .animation(.default, value: viewModel.sortOption)
            
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
        }
    }
    
    private var titleScreen: some View {
        Text.makeScreenTitle(titleText: "Моя история")
    }
    
    private var filterView: some View {
        VStack(spacing: 12) {
            DatePicker(
                "Начало",
                selection: Binding(
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
        .pickerStyle(.segmented)
    }
}

#Preview {
    let container = try! ModelContainer(for: BankAccountStorage.self, TransactionStorage.self, CategoryStorage.self, BackupOperationStorage.self)
        TabBarApp(modelContainer: container)
    MyHistoryView(direction: .outcome, modelContainer: container)
}
