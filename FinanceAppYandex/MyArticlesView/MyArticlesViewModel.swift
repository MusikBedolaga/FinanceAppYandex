//
//  MyArticlesViewModel.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 28.06.2025.
//

import Foundation
import SwiftUI


final class MyArticlesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    
    private let categoriesService = CategoriesService()
    private lazy var fuseSearch = FuseService()
    
    @MainActor
    func loadCategories() async {
        self.categories = await categoriesService.getAll()
        
        var categoriesName: [String] = categories.map { return $0.name }
        
        fuseSearch.updateData(categoriesName)
    }
    
    func filteredCategories(searchText: String) -> [Category] {
        guard !searchText.isEmpty else { return categories }
        let matches = fuseSearch.search(searchText)
        return matches.compactMap { match in
            categories.first(where: { $0.name == match.0 })
        }
    }
}
