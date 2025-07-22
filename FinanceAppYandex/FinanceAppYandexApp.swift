//
//  FinanceAppYandexApp.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 13.06.2025.
//

import SwiftUI
import SwiftData

@main
struct FinanceAppYandexApp: App {
    let container: ModelContainer
    
    init() {
        APIKeysStorage.shared.saveBaseURL("https://shmr-finance.ru/api/v1/")
        APIKeysStorage.shared.saveToken("KDmvzKKqKHjGNYlGj3tfcffj")
        
        do {
            container = try ModelContainer(
                for: BankAccountStorage.self,
                    TransactionStorage.self,
                    CategoryStorage.self,
                    BackupOperationStorage.self
            )
        } catch {
            fatalError("Failed to initialize database: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarApp(modelContainer: container)
                .modelContainer(container)
        }
    }
}

