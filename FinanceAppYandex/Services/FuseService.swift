//
//  FuseService.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 04.07.2025.
//

import Foundation
import Fuse

final class FuseService {
    private let fuse = Fuse()
    private var data: [String] = []
    
    init() { }
    
    init(data: [String]) {
        self.data = data
    }
    
    func updateData(_ newData: [String]) {
        data = newData
    }
    
    func search(_ query: String, threshold: Double = 0.5) -> [(String, Double)] {
        return data.compactMap {
            if let result = fuse.search(query, in: $0), result.score < threshold {
                return ($0, result.score)
            }
            return nil
        }
        .sorted { $0.1 < $1.1 }
    }
}
