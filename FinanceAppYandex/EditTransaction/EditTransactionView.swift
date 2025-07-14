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

    init(direction: Direction, transaction: Transaction? = nil) {
        self.direction = direction
        self.isEdit = transaction != nil
        _viewModel = StateObject(wrappedValue: EditTransactionViewModel(direction: direction, transaction: transaction))
        if let transaction {
            _amountText = State(initialValue: "\(transaction.amount)")
        }
    }

    var body: some View {
        Group {
            if let transaction = viewModel.transaction {
                content(transaction: transaction)
            } else {
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
        .onChange(of: viewModel.transaction?.id) { newID in
            if let tx = viewModel.transaction, amountText.isEmpty {
                amountText = "\(tx.amount)"
            }
        }
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.dismissAlert() } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(viewModel.alertMessage ?? "Неизвестная ошибка"),
                dismissButton: .default(Text("Ок")) { viewModel.dismissAlert() }
            )
        }
    }

    private func content(transaction: Transaction) -> some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text(direction == .income ? "Мои доходы" : "Мои расходы")
                    .font(.largeTitle).bold()
                    .padding(.horizontal)

                VStack(spacing: 0) {
                    categoryView(transaction: transaction)
                    divider
                    amountView(transaction: transaction)
                    divider
                    dateView(transaction: transaction)
                    divider
                    timeView(transaction: transaction)
                    divider
                    descriptionView(transaction: transaction)
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 10)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)

                if isEdit { deleteTransactionView() }

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
                            viewModel.transaction?.amount = amount
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
                    selectedCategory: Binding(
                        get: { viewModel.transaction?.category ?? transaction.category },
                        set: { viewModel.transaction?.category = $0 }
                    )
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

    private func categoryView(transaction: Transaction) -> some View {
        Button(action: { showCategoryPicker.toggle() }) {
            HStack {
                Text("Статья").foregroundColor(.black)
                Spacer()
                Text(transaction.category.name).foregroundColor(.gray)
                Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
            }
            .font(.system(size: 17))
            .padding()
        }
    }

    private func amountView(transaction: Transaction) -> some View {
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
            Text(transaction.account.currency).foregroundColor(.gray)
        }
        .font(.system(size: 17))
        .padding()
    }

    private func dateView(transaction: Transaction) -> some View {
        VStack {
            HStack {
                Text("Дата").foregroundColor(.black)
                Spacer()
                Button(action: { withAnimation { isDateExpanded.toggle() } }) {
                    Text(transaction.transactionDate.formatted(.dateTime.day().month(.wide)))
                        .padding(6)
                        .padding(.horizontal, 8)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .font(.system(size: 17))
            .padding()

            if isDateExpanded {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.transaction?.transactionDate ?? transaction.transactionDate },
                        set: { viewModel.transaction?.transactionDate = $0 }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .accentColor(Color.green)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
    }

    private func timeView(transaction: Transaction) -> some View {
        HStack {
            Text("Время")
            Spacer()
            Button(action: { showTimePicker = true }) {
                Text(transaction.transactionDate.formatted(date: .omitted, time: .shortened))
                    .padding(6)
                    .padding(.horizontal, 8)
                    .background(Color.green.opacity(0.2))
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
                    selection: Binding(
                        get: { viewModel.transaction?.transactionDate ?? transaction.transactionDate },
                        set: { viewModel.transaction?.transactionDate = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .accentColor(Color.green)
                .padding()
                Button("Готово") { showTimePicker = false }
                    .foregroundColor(.purple)
                    .padding()
            }
            .presentationDetents([.fraction(0.3)])
        }
    }

    private func descriptionView(transaction: Transaction) -> some View {
        TextField("Комментарий", text: Binding(
            get: { viewModel.transaction?.comment ?? "" },
            set: { viewModel.transaction?.comment = $0 }
        ))
        .font(.system(size: 17))
        .padding()
    }

    private func deleteTransactionView() -> some View {
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
            
            if viewModel.isLoading {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.8)
            }
        }
        .onAppear {
            Task { await viewModel.fetch() }
        }
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.dismissAlert() } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(viewModel.alertMessage ?? "Неизвестная ошибка"),
                dismissButton: .default(Text("Ок")) { viewModel.dismissAlert() }
            )
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
