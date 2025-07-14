//
//  FinanceAppYandexApp.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 13.06.2025.
//

import SwiftUI

@main
struct FinanceAppYandexApp: App {
    
    init() {
        APIKeysStorage.shared.saveBaseURL("https://shmr-finance.ru/api/v1/")
        APIKeysStorage.shared.saveToken("KDmvzKKqKHjGNYlGj3tfcffj")
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarApp()
        }
    }
}
