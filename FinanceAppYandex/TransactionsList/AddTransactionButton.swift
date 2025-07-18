//
//  AddTransactionButton.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import SwiftUI

struct AddTransactionButton: View {
    @Binding var isPresented: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            isPresented = true
            action()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.green)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
}
