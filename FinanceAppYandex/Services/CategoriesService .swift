//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation
import SwiftData


actor CategoriesService {
    
    private var fuseSearch = FuseService()
    let network: NetworkService
    let localStorage: SwiftDataCategoryStorage
    
    init(network: NetworkService, modelContainer: ModelContainer) {
        self.network = network
        self.localStorage = SwiftDataCategoryStorage(modelContainer: modelContainer)
    }
    
    func getAll() async throws -> [Category] {
        do {
            let categories: [Category] = try await network.request(endpoint: "categories")
                
            do {
                _ = try await localStorage.saveCategories(categories)
            } catch {
                throw error
            }
                
            updateFuseData(with: categories)
            return categories
                
        } catch {
            do {
                let localCategories = try await localStorage.fetchAllCategories()
                updateFuseData(with: localCategories)
                return localCategories
            } catch {
                throw error
            }
        }
    }
    
    func getById(by id: Int) async throws -> Category {
        let all = try await getAll()
        guard let category = all.first(where: { $0.id == id }) else {
            throw NSError(domain: "Category", code: 404, userInfo: [NSLocalizedDescriptionKey: "Категория с id \(id) не найдена"])
        }
        return category
    }

    func getIncomeOrOutcome(direction: Direction) async throws -> [Category] {
        let isIncome = (direction == .income)
        let endpoint = "categories/type/\(isIncome)"
        do {
            let categories: [Category] = try await network.request(endpoint: endpoint)
            do {
                _ = try await localStorage.saveCategories(categories)
            } catch {
                print("Ошибка сохранения локально: \(error)")
            }
            updateFuseData(with: categories)
            return categories
        } catch {
            let allLocalCategories = try await localStorage.fetchAllCategories()
            let filtered = allLocalCategories.filter { $0.isIncome == isIncome }
            updateFuseData(with: filtered)
            return filtered
        }
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
