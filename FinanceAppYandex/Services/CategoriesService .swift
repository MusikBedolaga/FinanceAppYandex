//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


actor CategoriesService {
    private var fuseSearch = FuseService()
    
    func getAll() async -> [Category] {
        return [
            Category(id: 1, name: "Зарплата", emoji: "💵", isIncome: true),
            Category(id: 2, name: "Лечение зубов", emoji: "🦷", isIncome: false),
            Category(id: 3, name: "Продукты", emoji: "🧺", isIncome: false)
        ]
    }

    func getIncomeOrOutcome(direction: Direction) async -> [Category] {
        let allCategories = await getAll()
        return allCategories.filter { $0.direction == direction }
    }
    
    func updateFuseData(with categories: [Category]) {
        let names = categories.map { $0.name }
        fuseSearch.updateData(names)
    }

    func searchCategories(all categories: [Category], searchText: String) async -> [Category] {
        if searchText.isEmpty { return categories }
        let matches = fuseSearch.search(searchText)
        return matches.compactMap { match in
            categories.first(where: { $0.name == match.0 })
        }
    }
}

