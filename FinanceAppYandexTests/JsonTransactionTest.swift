//
//  JsonTransactionTest.swift
//  FinanceAppTests
//
//  Created by Муса Зарифянов on 09.06.2025.
//

import Foundation
import XCTest

@testable import FinanceAppYandex

class JsonTransactionTest: XCTestCase {
    
    var category: FinanceAppYandex.Category!
    
    var bankAccount: BankAccount!
    
    var transaction: Transaction!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        category = Category(
            id: 5,
            name: "Зарплата",
            emoji: "💵",
            isIncome: true
        )
        
        bankAccount = BankAccount(
            id: 5,
            userId: 1,
            name: "Сберегательный счет",
            balance: 100000,
            currency: "$",
            createdAt: nil,
            updatedAt: nil
        )
        
        transaction = Transaction(
            id: 8,
            account: bankAccount,
            category: category,
            amount: 100,
            transactionDate: Date(),
            comment: "Кент вернул сотку",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    override func tearDownWithError() throws {
        category = nil
        bankAccount = nil
        transaction = nil
        
        try super.tearDownWithError()
    }
    
    ///  Проверка json -> transaction и наоборот
    func testTransactionJsonSerializationAndParsing() throws {
        let json = transaction.jsonObject
        
        guard let parsedTransaction = Transaction.parse(jsonObject: json) else {
            XCTFail("Не удалось распарсить transaction из JSON")
            return
        }
        
        XCTAssertEqual(parsedTransaction.id, transaction.id)
        XCTAssertEqual(parsedTransaction.amount, transaction.amount)
        XCTAssertEqual(parsedTransaction.comment, transaction.comment)
        XCTAssertEqual(parsedTransaction.category.id, transaction.category.id)
        XCTAssertEqual(parsedTransaction.category.name, transaction.category.name)
        XCTAssertEqual(parsedTransaction.category.emoji, transaction.category.emoji)
        XCTAssertEqual(parsedTransaction.category.isIncome, transaction.category.isIncome)
        XCTAssertEqual(parsedTransaction.account.id, transaction.account.id)
        XCTAssertEqual(parsedTransaction.account.name, transaction.account.name)
        XCTAssertEqual(parsedTransaction.account.currency, transaction.account.currency)
        XCTAssertEqual(parsedTransaction.account.balance, transaction.account.balance)
    }
    
    /// Проверка json
    func testInvalidJsonParsingReturnsNil() {
        let invalidJson: Any = ["invalidKey": "value"]
        
        let result = Transaction.parse(jsonObject: invalidJson)
        
        XCTAssertNil(result, "Ожидалось nil при попытке парсить невалидный JSON")
    }
}
