//
//  MyAccountView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 22.06.2025.
//

import Foundation
import SwiftUI
import CoreMotion

struct MyAccountView: View {
    @StateObject var viewModel = MyAccountViewModel()
    @State private var isEditing = false
    @State private var showCurrencyPicker = false
    @State private var selectedCurrency = currencies[0]
    @FocusState private var balanceIsFocused: Bool
    
    @State private var isBalanceHidden = false
    @State private var lastShakeTime: Date? = nil
    @StateObject private var detector = ShakeDetector()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.backgroundScreenColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    titleScreen
                    balanceView
                    currencyView
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
        }
        .onAppear {
            selectedCurrency = currencyForSymbol(viewModel.editingCurrency)
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

    private func currencyForSymbol(_ symbol: String) -> Currency {
        currencies.first { $0.symbol == symbol } ?? currencies[0]
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    MyAccountView()
}
