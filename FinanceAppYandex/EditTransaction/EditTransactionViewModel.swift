import Foundation

@MainActor
final class EditTransactionViewModel: ObservableObject {
    @Published var transaction: Transaction
    @Published var isLoading = false
    @Published var errorMessage: String?
    

    private let transactionService = TransactionsService.shared
    private let direction: Direction

    init(transaction: Transaction, direction: Direction) {
        self.transaction = transaction
        self.direction = direction
    }
    
    init(direction: Direction) {
        self.direction = direction
        
        self.transaction = direction == .income ?
            transactionService.defaultTransactionIncome() : transactionService.defaultTransactionOutcome()
    }
    
    func addTransaction() async {
        isLoading = true
        defer { isLoading = false }
        
        await transactionService.add(transaction)
    }

    func saveTransaction() async {
        isLoading = true
        defer { isLoading = false }

        await transactionService.update(transaction)
    }

    func deleteTransaction() async {
        isLoading = true
        defer { isLoading = false }

        await transactionService.delete(id: transaction.id)
    }
    
    func sanitize(_ input: String) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let allowedCharacters = CharacterSet(charactersIn: "0123456789" + decimalSeparator)
        var filtered = input.filter { String($0).rangeOfCharacter(from: allowedCharacters) != nil }
        
        let parts = filtered.components(separatedBy: decimalSeparator)
        if parts.count > 2 {
            filtered = parts[0] + decimalSeparator + parts[1]
        }
        return filtered
    }
    
    func validate(amountText: String) -> String? {
        guard let amount = Decimal(string: amountText), amount > 0 else {
            return "Пожалуйста, введите корректную сумму"
        }
        if transaction.category.name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Пожалуйста, выберите категорию"
        }
        
        if (transaction.comment ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Пожалуйста, введите комментарий"
        }
        
        return nil
    }
}


@MainActor
final class CategoryPickerViewModel: ObservableObject {
    @Published var categoies: [Category] = []
    
    private let direction: Direction
    private let categoryService = CategoriesService()
    
    init(direction: Direction) {
        self.direction = direction
        
        Task {
            categoies = await fetchCategories(direction: direction)
        }
    }
    
    private func fetchCategories(direction: Direction) async -> [Category] {
        await categoryService.getIncomeOrOutcome(direction: direction)
    }
}
