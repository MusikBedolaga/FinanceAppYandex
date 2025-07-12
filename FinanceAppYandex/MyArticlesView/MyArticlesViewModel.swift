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

    private let categoriesService = CategoriesService()

    func loadCategories() {
        Task {
            let loadedCategories = await categoriesService.getAll()
            await MainActor.run {
                self.categories = loadedCategories
                self.filteredCategories = loadedCategories
            }
            await categoriesService.updateFuseData(with: loadedCategories)
        }
    }

    func searchCategories(searchText: String) {
        Task {
            let filtered = await categoriesService.searchCategories(all: categories, searchText: searchText)
            await MainActor.run {
                self.filteredCategories = filtered
            }
        }
    }
}



