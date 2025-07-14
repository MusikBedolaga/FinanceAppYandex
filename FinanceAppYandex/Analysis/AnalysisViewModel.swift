import Foundation

@MainActor
final class AnalysisViewModel {
    private var transactionService: TransactionsService?

    var transactions: [Transaction] = []
    var direction: Direction
    var startDate: Date
    var endDate: Date
    var totalAmountForDate: Decimal = 0
    var sortOption: SortOptions = .none

    var onTransactionsUpdated: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(direction: Direction) {
        self.direction = direction
        let (start, end) = Self.getDefaultTime()
        self.startDate = start
        self.endDate = end
    }

     func fetchTransactions() {
        if transactionService == nil {
            guard
                let baseURL = APIKeysStorage.shared.getBaseURL(),
                let token = APIKeysStorage.shared.getToken()
            else {
                self.onError?("Нет данных для подключения к API")
                return
            }
            let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
            self.transactionService = TransactionsService(network: network)
        }

        guard let transactionService else {
            self.onError?("Service not initialized")
            transactions = []
            return
        }

        let direction = self.direction
        let startDate = self.startDate
        let endDate = self.endDate
        let sortOption = self.sortOption

        self.onLoadingChanged?(true)

        Task {
            defer {
                Task { @MainActor in self.onLoadingChanged?(false) }
            }
            do {
                let txs = try await transactionService.getFiltered(
                    direction: direction,
                    startDate: startDate,
                    endDate: endDate,
                    sortOption: sortOption
                )
                let total = try await transactionService.totalAmount(
                    direction: direction,
                    startDate: startDate,
                    endDate: endDate
                )

                await MainActor.run { [weak self] in
                    self?.transactions = txs
                    self?.totalAmountForDate = total
                    self?.onTransactionsUpdated?()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
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
