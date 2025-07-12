import Foundation

@MainActor
final class AnalysisViewModel {
    private var transactionService = TransactionsService.shared

    var transactions: [Transaction] = []
    var direction: Direction
    var startDate: Date
    var endDate: Date
    var totalAmountForDate: Decimal = 0
    var onTransactionsUpdated: (() -> Void)?
    var sortOption: SortOptions = .none

    init(direction: Direction) {
        self.direction = direction
        let (start, end) = Self.getDefaultTime()
        self.startDate = start
        self.endDate = end

        fetchTransactions()
    }

    func fetchTransactions() {
        let direction = self.direction
        let startDate = self.startDate
        let endDate = self.endDate
        let sortOption = self.sortOption
        let service = self.transactionService

        Task {
            let txs = await service.getFiltered(
                direction: direction,
                startDate: startDate,
                endDate: endDate,
                sortOption: sortOption
            )
            let total = await service.totalAmount(
                direction: direction,
                startDate: startDate,
                endDate: endDate
            )

            await MainActor.run { [weak self] in
                self?.transactions = txs
                self?.totalAmountForDate = total
                self?.onTransactionsUpdated?()
            }
        }
    }

    func setStartTime(_ date: Date) {
        startDate = date
        if startDate > endDate {
            endDate = startDate
        }
        fetchTransactions()
    }

    func setFinishTime(_ date: Date) {
        endDate = date
        if endDate < startDate {
            startDate = endDate
        }
        fetchTransactions()
    }

    func updateSortOption(to option: SortOptions) {
        sortOption = option
        fetchTransactions()
    }

    private static func getDefaultTime() -> (Date, Date) {
        let now = Date()
        let calendar = Calendar.current
        let defaultEnd = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: now)!
        let defaultStart = calendar.date(byAdding: .day, value: -30, to: defaultEnd)!
            .settingTime(hour: 0, minute: 0)!
        return (defaultStart, defaultEnd)
    }
}
