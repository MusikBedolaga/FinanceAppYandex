import Foundation

@MainActor
final class AnalysisViewModel {
    
    private var transactionService = TransactionsService.shared
    private var originalTransactions: [Transaction] = []
    
    var transactions = [Transaction]()
    var direction: Direction
    var startDate: Date
    var endDate: Date
    var totalAmountForDate: Decimal = 0
    var onTransactionsUpdated: (() -> Void)?
    var sortOption: SortOptions = .none
    
    init(direction: Direction) {
        self.direction = direction
        let (start, end) = Self.getDefaultTime()
        startDate = start
        endDate = end
        
        Task {
            await fetchTransactions()
        }
    }
    
    func fetchTransactions() async {
        let allTransactionForDate = await transactionService.get(from: startDate, to: endDate)
        let filtered = allTransactionForDate.filter { $0.category.direction == self.direction }
        
        self.transactions = filtered
        self.originalTransactions = filtered
        
        calculateTotalAmountForDate()
        setOption(sortOption)
        onTransactionsUpdated?()
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
            startDate = endDate
        }
        Task {
            await fetchTransactions()
        }
    }
    
    func updateSortOption(to option: SortOptions) {
        sortOption = option
        setOption(option)
    }
    
    private static func getDefaultTime() -> (Date, Date) {
        let now = Date()
        let calendar = Calendar.current
        let defaultEnd = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: now)!
        let defaultStart = calendar.date(byAdding: .day, value: -30, to: defaultEnd)!
            .settingTime(hour: 0, minute: 0)!
        return (defaultStart, defaultEnd)
    }
    
    private func calculateTotalAmountForDate() {
        totalAmountForDate = transactions.reduce(0) { $0 + $1.amount}
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
}
