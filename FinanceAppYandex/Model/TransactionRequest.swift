import Foundation

struct TransactionRequest: Codable {
    let amount: String
    let categoryId: Int
    let accountId: Int
    let transactionDate: String
    let comment: String?

    init(from transaction: Transaction) {
        self.amount = Self.formatAmount(transaction.amount)
        self.categoryId = transaction.category.id
        self.accountId = transaction.account.id
        self.transactionDate = Self.isoFormatter.string(from: transaction.transactionDate)
        self.comment = transaction.comment
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

    private static func formatAmount(_ amount: Decimal) -> String {
        let nsDecimal = NSDecimalNumber(decimal: amount)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: nsDecimal) ?? nsDecimal.stringValue
    }
}


