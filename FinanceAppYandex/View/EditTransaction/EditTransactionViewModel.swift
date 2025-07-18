import Foundation
import SwiftData

@MainActor
final class EditTransactionViewModel: ObservableObject {
    @Published var transaction: Transaction?
    @Published var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private let transactionService: TransactionsService
    private let modelContainer: ModelContainer
    private let direction: Direction

    init(direction: Direction, transaction: Transaction? = nil, modelContainer: ModelContainer) {
        self.direction = direction
        self.modelContainer = modelContainer
        
        guard
            let baseURL = APIKeysStorage.shared.getBaseURL(),
            let token = APIKeysStorage.shared.getToken()
        else {
            fatalError("Нет данных для подключения к API")
        }
        let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
        self.transactionService = TransactionsService(network: network, modelContainer: modelContainer)

        self.transaction = transaction
        if transaction == nil {
            Task { await loadDefaultTransaction() }
        }
    }

    private func loadDefaultTransaction() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if direction == .income {
                transaction = try await transactionService.defaultTransactionIncome()
            } else {
                transaction = try await transactionService.defaultTransactionOutcome()
            }
        } catch {
            errorMessage = "Не удалось создать шаблон транзакции: \(error.localizedDescription)"
        }
    }

    func addTransaction() async {
        guard let transaction else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await transactionService.add(transaction)
            alertMessage = "Транзакция успешно добавлена"
        } catch {
            errorMessage = "Ошибка при добавлении: \(error.localizedDescription)"
        }
    }

    func saveTransaction() async {
        guard let transaction else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await transactionService.update(transaction: transaction)
            alertMessage = "Транзакция успешно обновлена"
        } catch {
            errorMessage = "Ошибка при сохранении: \(error.localizedDescription)"
        }
    }

    func deleteTransaction() async {
        guard let transaction else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await transactionService.delete(transaction: transaction)
            alertMessage = "Транзакция удалена"
        } catch {
            errorMessage = "Ошибка при удалении: \(error.localizedDescription)"
        }
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
        guard let transaction else {
            return "Транзакция ещё загружается"
        }
        if transaction.category.name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Пожалуйста, выберите категорию"
        }
        if (transaction.comment ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Пожалуйста, введите комментарий"
        }
        return nil
    }

    func dismissAlert() {
        alertMessage = nil
    }
}



@MainActor
final class CategoryPickerViewModel: ObservableObject {
    @Published var categoies: [Category] = []
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    
    private let direction: Direction
    private var categoryService: CategoriesService?
    private let modelContainer: ModelContainer
    
    init(direction: Direction, modelContainer: ModelContainer) {
        self.direction = direction
        self.modelContainer = modelContainer
    }

    func fetch() async {
        if categoryService == nil {
            guard
                let baseURL = APIKeysStorage.shared.getBaseURL(),
                let token = APIKeysStorage.shared.getToken()
            else {
                self.alertMessage = "Нет данных для подключение к API"
                return
            }
            let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
            self.categoryService = CategoriesService(network: network, modelContainer: modelContainer)
        }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let _ = categoryService else {
            alertMessage = "Service not initialized"
            categoies = []
            return
        }
        
        do {
            let cats = try await fetchCategories(direction: direction)
            await MainActor.run {
                self.categoies = cats
            }
        } catch {
            self.alertMessage = error.localizedDescription
            self.categoies = []
        }
    }
    
    private func fetchCategories(direction: Direction) async throws -> [Category] {
        guard let categoryService else {
            throw NSError(domain: "CategoriesService is nil", code: 0)
        }
        return try await categoryService.getIncomeOrOutcome(direction: direction)
    }
    
    func dismissAlert() {
        alertMessage = nil
    }
}

