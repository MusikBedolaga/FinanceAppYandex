//
//  Extentions+Transaction.swift
//  FinanceApp
//
//  Created by Муса Зарифянов on 06.06.2025.
//

import Foundation


//MARK: - JSON
extension Transaction {
    
    var jsonObject: Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(self)
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            return object
        } catch {
            print("Failed to encode Transaction: \(error)")
            return [:]
        }
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        do {
            guard JSONSerialization.isValidJSONObject(jsonObject) else { return nil }
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Transaction.self, from: data)
        } catch {
            print("Failed to decode Transaction: \(error)")
            return nil
        }
    }
}


//MARK: - CSV
extension Transaction {
    static func parseCSV(from csv: String) -> [Transaction] {
        let rows = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard rows.count > 1 else { return [] }
        
        let header = rows[0].components(separatedBy: ",")
        guard header.count == 15 else { return [] }
        
        let dateFormatter = ISO8601DateFormatter()
        var result: [Transaction] = []
        
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            guard columns.count == 15 else { continue }
            
            guard
                let id = Int(columns[0]),
                let accountId = Int(columns[1]),
                let accountBalance = Decimal(string: columns[3]),
                let categoryId = Int(columns[5]),
                let categoryIsIncome = Bool(columns[8]),
                let amount = Decimal(string: columns[9]),
                let transactionDate = dateFormatter.date(from: columns[10]),
                let createdAt = dateFormatter.date(from: columns[12]),
                let updatedAt = dateFormatter.date(from: columns[13]),
                let userId = Int(columns[14])
            else {
                continue
            }
            
            let account = BankAccount(
                id: accountId,
                userId: userId,
                name: columns[2],
                balance: accountBalance,
                currency: columns[4],
                createdAt: nil,
                updatedAt: nil
            )
            
            guard let emoji = columns[7].first else { continue }
            
            let category = Category(
                id: categoryId,
                name: columns[6],
                emoji: emoji,
                isIncome: categoryIsIncome
            )
            
            let comment = columns[11].isEmpty ? nil : columns[11]
            
            let transaction = Transaction(
                id: id,
                account: account,
                category: category,
                amount: amount,
                transactionDate: transactionDate,
                comment: comment,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            
            result.append(transaction)
        }
        
        return result
    }
}


