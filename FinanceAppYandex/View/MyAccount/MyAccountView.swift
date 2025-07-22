import Foundation
import SwiftUI
import CoreMotion
import SwiftData
import Charts

struct MyAccountView: View {
    @StateObject var viewModel: MyAccountViewModel
    @State private var isEditing = false
    @State private var showCurrencyPicker = false
    @State private var selectedCurrency = currencies[0]
    @State private var selectedDate: Date?
    @State private var selectedValue: Decimal?
    @FocusState private var balanceIsFocused: Bool
    @State private var isBalanceHidden = false
    @State private var lastShakeTime: Date? = nil
    @StateObject private var detector = ShakeDetector()
    @State private var selectedRange: ChartRange = .daily

    init(modelContainer: ModelContainer) {
        _viewModel = StateObject(wrappedValue: MyAccountViewModel(modelContainer: modelContainer))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundScreenColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    titleScreen
                    balanceView
                    currencyView

                    if !isEditing {
                        chartRangePicker
                        chartView
                    }

                    Spacer()
                }
                .padding(.bottom, showCurrencyPicker ? 350 : 0)
                .animation(.easeInOut, value: showCurrencyPicker)
            }
            .refreshable {
                viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить": "Редактировать") {
                        toggleEditing()
                    }
                    .foregroundColor(.customPurple)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshToolbarItem
                }
            }

            if showCurrencyPicker {
                currencyPicker
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: showCurrencyPicker)
            }

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
        .onAppear {
            selectedCurrency = currencyForSymbol(viewModel.editingCurrency)
            Task {
                await viewModel.loadBankAccount()
                await viewModel.calculateStatisticsForAccounts()
            }
        }
        .onChange(of: detector.isShaking) { newValue in
            guard newValue else { return }
            let now = Date()
            if let last = lastShakeTime, now.timeIntervalSince(last) < 1 { return }
            lastShakeTime = now
            withAnimation(.easeInOut(duration: 0.4)) {
                isBalanceHidden.toggle()
            }
        }
        .onChange(of: showCurrencyPicker) { newValue in
            if newValue {
                hideKeyboard()
            }
        }
        .onChange(of: selectedRange) { newValue in
            Task {
                switch newValue {
                case .daily:
                    await viewModel.calculateStatisticsForAccounts()
                case .monthly:
                    await viewModel.calculateMonthlyStatistics()
                }
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.selectedRange = newValue
                    }
                }
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

    private var refreshToolbarItem: some View {
        Group {
            if !isEditing {
                if viewModel.isLoading {
                    ProgressView().tint(.customPurple)
                } else {
                    Button(action: { Task { viewModel.refresh() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.customPurple)
                    }
                }
            }
        }
    }

    private var currencyPicker: some View {
        CurrencyPickerView(selectedCurrency: $selectedCurrency) { currency in
            viewModel.editingCurrency = currency.symbol
            withAnimation {
                showCurrencyPicker = false
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(Color.backgroundScreenColor.shadow(radius: 8))
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }

    private func toggleEditing() {
        if isEditing {
            Task {
                await viewModel.saveChanges()
                isEditing = false
                balanceIsFocused = false
            }
        } else {
            isEditing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                balanceIsFocused = true
            }
        }
    }

    private var titleScreen: some View {
        Text.makeScreenTitle(titleText: "Мой счет")
            .padding()
    }

    private var balanceView: some View {
        HStack {
            Text("💰 Баланс")
                .padding(.leading, 16)
                .padding(.vertical, 12)

            Spacer()

            if isEditing {
                TextField(
                    "Баланс",
                    text: $viewModel.editingBalance
                )
                .keyboardType(.decimalPad)
                .focused($balanceIsFocused)
                .padding(.trailing, 16)
                .padding(.vertical, 12)
                .onChange(of: viewModel.editingBalance) { newValue in
                    let filtered = viewModel.filterBalanceInput(newValue)
                    if filtered != newValue {
                        viewModel.editingBalance = filtered
                    }
                }
            } else {
                Text(viewModel.formatedBalance)
                    .padding(.trailing, 16)
                    .padding(.vertical, 12)
                    .blur(radius: isBalanceHidden ? 8 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isBalanceHidden)
            }
        }
        .background(isEditing ? .white : Color.customGreen)
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }

    private var currencyView: some View {
        HStack {
            Text("Валюта")
                .padding(.leading, 16)
                .padding(.vertical, 12)

            Spacer()

            HStack {
                Text(viewModel.editingCurrency)
                
                if isEditing {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .padding(.trailing, 16)
            .padding(.vertical, 12)
        }
        .background(isEditing ? .white : Color.customLightGreen)
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .onTapGesture {
            if isEditing {
                withAnimation {
                    selectedCurrency = currencyForSymbol(viewModel.editingCurrency)
                    showCurrencyPicker = true
                }
            }
        }
    }

    private var chartRangePicker: some View {
        Picker("Диапазон", selection: $selectedRange) {
            ForEach(ChartRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var chartView: some View {
        let data = selectedRange == .daily
            ? viewModel.balanceStatistics
            : viewModel.monthlyBalanceStatistics

        return Chart {
            ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                BarMark(
                    x: .value("Date", item.key),
                    y: .value("Balance", abs(item.value))
                )
                .foregroundStyle(item.value < 0 ? .orange : .green)
                .annotation(position: .top, alignment: .center) {
                    if selectedDate == item.key, let value = selectedValue {
                        Text("\(value.formatted(.number.precision(.fractionLength(2))))")
                            .font(.caption)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        if selectedRange == .daily {
                            Text(date, format: .dateTime.day().month(.twoDigits))
                        } else {
                            Text(date, format: .dateTime.month().year(.twoDigits))
                        }
                    }
                }
            }
        }
        .chartYAxis {}
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let origin = geometry[proxy.plotAreaFrame].origin
                                let locationX = value.location.x - origin.x

                                if let date: Date = proxy.value(atX: locationX) {
                                    let closest = data.keys.min(by: {
                                        abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date))
                                    })
                                    if let closest = closest, let value = data[closest] {
                                        selectedDate = closest
                                        selectedValue = value
                                    }
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    selectedDate = nil
                                    selectedValue = nil
                                }
                            }
                    )
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.5), value: data)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func currencyForSymbol(_ symbol: String) -> Currency {
        currencies.first { $0.symbol == symbol } ?? currencies[0]
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: BankAccountStorage.self,
        TransactionStorage.self,
        CategoryStorage.self,
        BackupOperationStorage.self
    )
    MyAccountView(modelContainer: container)
}
