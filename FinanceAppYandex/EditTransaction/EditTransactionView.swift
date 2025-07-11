import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditTransactionViewModel
    @State private var amountText: String = ""
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var isDateExpanded = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    
    private let direction: Direction
    private let isEdit: Bool

    init(direction: Direction, transaction: Transaction?) {
        self.direction = direction
        if let transaction = transaction {
            self._viewModel = StateObject(wrappedValue: EditTransactionViewModel(transaction: transaction, direction: direction))
            self._amountText = State(initialValue: "\(transaction.amount)")
            isEdit = true
        } else {
            self._viewModel = StateObject(wrappedValue: EditTransactionViewModel(direction: direction))
            isEdit = false
        }
        
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text(direction == .income ? "Мои доходы" : "Мои расходы")
                    .font(.largeTitle).bold()
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    categoryView
                    divider
                    amountView
                    divider
                    dateView
                    divider
                    timeView
                    divider
                    descriptionView
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 10)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)

                if isEdit { deleteTransactionView }

                Spacer()
                
                
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.purple)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEdit ? "Сохранить" : "Создать") {
                        if let error = viewModel.validate(amountText: amountText) {
                            validationMessage = error
                            showValidationAlert = true
                            return
                        }
                        if let amount = Decimal(string: amountText) {
                            viewModel.transaction.amount = amount
                            Task {
                                if isEdit {
                                    await viewModel.saveTransaction()
                                } else {
                                    await viewModel.addTransaction()
                                }
                                dismiss()
                            }
                        }
                    }
                    .foregroundColor(.purple)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    direction: direction,
                    selectedCategory: $viewModel.transaction.category
                )
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .alert("Ошибка", isPresented: $showValidationAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }

    private var divider: some View {
        Divider().padding(.leading, 16)
    }

    private var categoryView: some View {
        Button(
            action: { showCategoryPicker.toggle() }) {
            HStack {
                Text("Статья")
                    .foregroundColor(.black) // Изменить
                Spacer()
                Text(viewModel.transaction.category.name)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .font(.system(size: 17))
            .padding()
        }
    }

    private var amountView: some View {
        HStack {
            Text("Сумма")
            Spacer()
            TextField("0.00", text: $amountText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.gray)
                .onChange(of: amountText) { newValue in
                    amountText = viewModel.sanitize(newValue)
                }
            Text(viewModel.transaction.account.currency).foregroundColor(.gray)
        }
        .font(.system(size: 17))
        .padding()
    }

    private var dateView: some View {
        VStack {
            HStack {
                Text("Дата")
                    .foregroundColor(.black)
                Spacer()
                Button(action: { withAnimation { isDateExpanded.toggle() } }) {
                    Text(viewModel.transaction.transactionDate.formatted(.dateTime.day().month(.wide)))
                        .padding(6)
                        .padding(.horizontal, 8)
                        .background(Color.customGreen.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .font(.system(size: 17))
            .padding()

            if isDateExpanded {
                DatePicker(
                    "",
                    selection: $viewModel.transaction.transactionDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accentColor(Color.customGreen)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
    }

    private var timeView: some View {
        HStack {
            Text("Время")
            Spacer()
            Button(action: {
                showTimePicker = true
            }) {
                Text(viewModel.transaction.transactionDate.formatted(date: .omitted, time: .shortened))
                    .padding(6)
                    .padding(.horizontal, 8)
                    .background(Color.customGreen.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .font(.system(size: 17))
        .padding()
        .sheet(isPresented: $showTimePicker) {
            VStack {
                DatePicker(
                    "",
                    selection: $viewModel.transaction.transactionDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .accentColor(Color.customGreen)
                .padding()

                Button("Готово") { showTimePicker = false }
                    .foregroundColor(.purple)
                    .padding()
            }
            .presentationDetents([.fraction(0.3)])
        }
    }

    private var descriptionView: some View {
        TextField("Комментарий", text: Binding(
            get: { viewModel.transaction.comment ?? "" },
            set: { viewModel.transaction.comment = $0 }
        ))
        .font(.system(size: 17))
        .padding()
    }

    private var deleteTransactionView: some View {
        Button(action: {
            Task {
                await viewModel.deleteTransaction()
                dismiss()
            }
        }) {
            Text(direction == .income ? "Удалить доход" : "Удалить расход")
                .foregroundColor(.red)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
                .padding(.top, 10)
        }
    }
}




// MARK: - CategoryPickerView
struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let direction: Direction
    @Binding var selectedCategory: Category
    @StateObject var viewModel: CategoryPickerViewModel
    
    init(direction: Direction, selectedCategory: Binding<Category>) {
        self.direction = direction
        self._selectedCategory = selectedCategory
        self._viewModel = StateObject(wrappedValue: CategoryPickerViewModel(direction: direction))
    }

    var body: some View {
        NavigationView {
            List(viewModel.categoies, id: \.id) { category in
                HStack {
                    Text(category.name)
                    Spacer()
                    if category.id == selectedCategory.id {
                        Image(systemName: "checkmark").foregroundColor(.purple)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCategory = category
                }
            }
            .navigationTitle("Выберите статью")
            .toolbar {
                Button("Готово") { dismiss() }
                    .foregroundColor(.purple)
            }
        }
    }
}


// MARK: - Preview
struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        EditTransactionView(
            direction: .income,
            transaction: Transaction(
                id: 1,
                account: BankAccount(id: 1, userId: 1, name: "Основной", balance: 1000, currency: "₽", createdAt: Date(), updatedAt: Date()),
                category: Category(id: 1, name: "Зарплата", emoji: "💼", isIncome: true),
                amount: 1000,
                transactionDate: Date(),
                comment: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    }
}
