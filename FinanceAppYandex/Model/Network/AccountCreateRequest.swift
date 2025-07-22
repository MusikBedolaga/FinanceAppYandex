//
//  AccountCreateRequest.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.07.2025.
//

import Foundation

struct AccountCreateRequest: Codable {
    let name: String
    let balance: String
    let currency: String
}
