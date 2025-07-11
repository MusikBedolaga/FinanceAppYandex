//
//  MyArticlesCellView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 29.06.2025.
//

import Foundation
import SwiftUI

struct MyArticlesCellView: View {
    var category: Category
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemMint).opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(String(category.emoji))
                    .font(.title2)
            }
            
            Text(category.name)
                .font(.system(size: 20))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}
