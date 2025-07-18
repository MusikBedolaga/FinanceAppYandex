//
//  SearchBarApp.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 28.06.2025.
//

import Foundation
import SwiftUI

struct SearchBarApp: View {
    @Binding var text: String
    var onMicTap: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                
            
            TextField("Search", text: $text)
                .foregroundColor(.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    UIApplication.shared.endEditing(true)
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct SearchBarApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                SearchBarApp(text: .constant(""))
                SearchBarApp(text: .constant("Test query"))
            }
            .background(Color(.systemGray6))
            .previewLayout(.sizeThatFits)
        }
    }
}
