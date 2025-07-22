//
//  MyArticlesViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 28.06.2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class MyArticlesViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var filteredCategories: [Category] = []
    @Published private(set) var isLoading = false
    @Published var alertMessage: String? = nil
    
    private let categoriesService: CategoriesService
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        
        guard let baseURL = APIKeysStorage.shared.getBaseURL(),
              let token = APIKeysStorage.shared.getToken() else {
            fatalError("API configuration is missing")
        }
        
        let network = NetworkService(baseURL: baseURL, token: token, session: .shared)
        self.categoriesService = CategoriesService(network: network, modelContainer: modelContainer)
    }
    
    func loadCategories() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loaded = try await categoriesService.getAll()
            await categoriesService.updateFuseData(with: loaded)
            
            categories = loaded
            filteredCategories = loaded
        } catch {
            alertMessage = error.localizedDescription
            categories = []
            filteredCategories = []
        }
    }
    
    func searchCategories(searchText: String) {
        Task {
            let filtered = await categoriesService.searchCategories(
                all: categories,
                searchText: searchText
            )
            filteredCategories = filtered
        }
    }
    
    func dismissAlert() {
        alertMessage = nil
    }
}



