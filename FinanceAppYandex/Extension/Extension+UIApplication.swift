//
//  Extension+UIApplication.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 29.06.2025.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .endEditing(force)
    }
}
