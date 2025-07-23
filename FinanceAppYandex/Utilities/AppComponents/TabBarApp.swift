//
//  TabBarApp.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI
import SwiftData

struct TabBarApp: View {
    @State private var selectedTab = 0
    @StateObject private var networkStatus = NetworkStatusService.shared

    let modelContainer: ModelContainer

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                // Вкладка 1 - Расходы
                NavigationStack {
                    TransactionsListView(titleText: "Экран расходов", direction: .outcome, modelContainer: modelContainer)
                }
                    .tabItem {
                        Label("Расходы", systemImage: "arrow.down.circle.fill")
                    }
                    .tag(0)
                
                // Вкладка 2 - Доходы
                NavigationStack {
                    TransactionsListView(titleText: "Экран доходов", direction: .income, modelContainer: modelContainer)
                }
                    .tabItem {
                        Label("Доходы", systemImage: "arrow.up.circle.fill")
                    }
                    .tag(1)
                
                // Вкладка 3 - Счет
                NavigationStack {
                    MyAccountView(modelContainer: modelContainer)
                }
                    .tabItem {
                        Label("Счет", systemImage: "wallet.pass.fill")
                    }
                    .tag(2)
                
                // Вкладка 4 - Статьи
                NavigationStack {
                    MyArticlesView(modelContainer: modelContainer)
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

            if networkStatus.isOffline {
                OfflineBannerView()
                    .padding(.top, 8) // отступ от верхнего края SafeArea
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkStatus.isOffline)
    }
}


#Preview {
    let container = try! ModelContainer(for: BankAccountStorage.self, TransactionStorage.self, CategoryStorage.self, BackupOperationStorage.self)
        TabBarApp(modelContainer: container)
    TabBarApp(modelContainer: container)
}
