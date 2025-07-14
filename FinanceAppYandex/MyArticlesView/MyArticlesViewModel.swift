//
//  MyArticlesViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 28.06.2025.
//

import Foundation
import SwiftUI

@MainActor
final class MyArticlesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var filteredCategories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil

    private var categoriesService: CategoriesService?

    
    func loadCategories() async {
        if categoriesService == nil {
            guard
                let baseURL = APIKeysStorage.shared.getBaseURL(),
                let token = APIKeysStorage.shared.getToken()
            else {
                self.alertMessage = "Нет данных для подключение к API"
                return
            }
            let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
            self.categoriesService = CategoriesService(network: network)
            
        }
        
        isLoading = true
        defer { isLoading = false }
        
        
        guard let categoriesService else {
            alertMessage = "Service not initialized"
            categories = []
            return
        }
                
        do {
            let loaded = try await categoriesService.getAll()
            await categoriesService.updateFuseData(with: loaded)
            withAnimation {
                categories = loaded
                filteredCategories = loaded
            }
        }
        catch {
            alertMessage = error.localizedDescription
            self.categories = []
        } 
    }

    func searchCategories(searchText: String) {
        Task {
            guard let categoriesService else { return }
            let filtered = await categoriesService.searchCategories(all: categories, searchText: searchText)
            await MainActor.run {
                self.filteredCategories = filtered
            }
        }
    }
    
    func dismissAlert() {
        alertMessage = nil
    }
}



