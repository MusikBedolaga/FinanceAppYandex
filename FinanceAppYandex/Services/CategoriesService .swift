//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


actor CategoriesService {
    
    private var fuseSearch = FuseService()
    let network: NetworkService
    
    init(network: NetworkService) {
        self.network = network
    }
    
    func getAll() async throws -> [Category] {
        try await network.request(endpoint: "categories")
    }

    func getIncomeOrOutcome(direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income ? true : false
        let categories: [Category] = try await network.request(endpoint: "categories/type/\(isIncome)")
        return categories
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
