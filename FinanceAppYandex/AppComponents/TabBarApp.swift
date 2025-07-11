//
//  TabBarApp.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI

struct TabBarApp: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Вкладка 1 - Расходы
            NavigationStack {
                TransactionsListView(titleText: "Экран расходов", direction: .outcome)
            }
                .tabItem {
                    Label("Расходы", systemImage: "arrow.down.circle.fill")
                }
                .tag(0)
            
            // Вкладка 2 - Доходы
            NavigationStack {
                TransactionsListView(titleText: "Экран доходов", direction: .income)
            }
                .tabItem {
                    Label("Доходы", systemImage: "arrow.up.circle.fill")
                }
                .tag(1)
            
            // Вкладка 3 - Счет
            NavigationStack {
                MyAccountView()
            }
                .tabItem {
                    Label("Счет", systemImage: "wallet.pass.fill")
                }
                .tag(2)
            
            // Вкладка 4 - Статьи
            NavigationStack {
                MyArticlesView()
            }
                .tabItem {
                    Label("Статьи", systemImage: "list.bullet.rectangle")
                }
                .tag(3)
            
            // Вкладка 5 - Настройки
            Text("Экран настроек")
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tabBarBackground(color: UIColor.white)
    }
}

#Preview {
    TabBarApp()
}
