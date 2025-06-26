//
//  CurrencyPickerView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 22.06.2025.
//

import Foundation
import SwiftUI

struct Currency: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let symbol: String
}

let currencies = [
    Currency(title: "Российский рубль", symbol: "₽"),
    Currency(title: "Американский доллар", symbol: "$"),
    Currency(title: "Евро", symbol: "€")
]


import SwiftUI

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: Currency
    var onSelect: ((Currency) -> Void)?

    var body: some View {
        VStack {
            Text("Валюта")
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            ForEach(currencies) { currency in
                Button {
                    guard currency != selectedCurrency else { return }
                    selectedCurrency = currency
                    onSelect?(currency)
                } label: {
                    Text("\(currency.title) \(currency.symbol)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.customPurple)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .contentShape(Rectangle())
                }

                if currency != currencies.last {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(white: 0.9)))
        .padding()
    }
}

