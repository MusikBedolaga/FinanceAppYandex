import Foundation

@MainActor
final class AnalysisViewModel {
    var transactions = [Transaction]()
    var transactionService = TransactionsService()
    var direction: Direction
    var startDate: Date
    var endDate: Date
    var totalAmountForDate: Decimal = 0
    var onTransactionsUpdated: (() -> Void)?
    
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
        transactions = transactionService.getAll()
        calculateTotalAmountForDate()
        onTransactionsUpdated?()
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
    
}
