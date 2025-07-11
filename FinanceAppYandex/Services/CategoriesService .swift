//
//  CategoriesService.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


final class CategoriesService {
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
}

