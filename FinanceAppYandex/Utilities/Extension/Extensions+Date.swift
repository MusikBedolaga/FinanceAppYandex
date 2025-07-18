//
//  Extensions+Date.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 16.06.2025.
//

import Foundation

extension Date {
    func settingTime(hour: Int, minute: Int) -> Date? {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)
    }
}

