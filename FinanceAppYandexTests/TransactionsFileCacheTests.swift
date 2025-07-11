//
//  TransactionsFileCacheTest.swift
//  FinanceAppTests
//
//  Created by Муса Зарифянов on 12.06.2025.
//

import XCTest
@testable import FinanceAppYandex

final class TransactionsFileCacheTests: XCTestCase {
    var cache: TransactionsFileCache!
    let fileName = "test_transactions"

    override func setUpWithError() throws {
        try super.setUpWithError()
        cache = TransactionsFileCache(fileName: fileName)
    }

    override func tearDownWithError() throws {
        let fileManager = FileManager.default
        let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("\(fileName).json")
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        try super.tearDownWithError()
    }

    func testAddAndRemoveTransaction() throws {
        let transaction = makeSampleTransaction(id: 1)
        cache.add(transaction)
        XCTAssertEqual(cache.transactions.count, 1)
        XCTAssertEqual(cache.transactions.first?.id, 1)

        cache.remove(byId: 1)
        XCTAssertEqual(cache.transactions.count, 0)
    }

    func testSaveAndLoadTransactions() throws {
        let transaction1 = makeSampleTransaction(id: 1)
        let transaction2 = makeSampleTransaction(id: 2)
        cache.add(transaction1)
        cache.add(transaction2)

        try cache.save()

        let newCache = TransactionsFileCache(fileName: fileName)
        try newCache.load()

        XCTAssertEqual(newCache.transactions.count, 2)
        XCTAssertEqual(newCache.transactions[0].id, 1)
        XCTAssertEqual(newCache.transactions[1].id, 2)
    }

    private func makeSampleTransaction(id: Int) -> Transaction {
        let category = Category(id: 1, name: "Groceries", emoji: "🛒", isIncome: false)
        let account = BankAccount(id: 1, userId: 1, name: "Main", balance: 1000, currency: "USD", createdAt: Date(), updatedAt: Date())
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: Decimal(100),
            transactionDate: Date(),
            comment: "Test transaction",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

