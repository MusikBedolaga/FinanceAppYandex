//
//  TransactionsFileCache.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


final class TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    private let fileURL: URL

    init(fileName: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documentsURL.appendingPathComponent("\(fileName).json")
    }

    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func remove(byId id: Int64) {
        transactions.removeAll { $0.id == id }
    }

    func save() throws {
        let foundationObjects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: foundationObjects, options: [.prettyPrinted])
        try data.write(to: fileURL, options: [.atomic])
    }

    func load() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            transactions = []
            return
        }

        let data = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: data, options: [])

        guard let jsonArray = json as? [Any] else {
            transactions = []
            return
        }

        transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
    }
}

