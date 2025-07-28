//
//  Extension+Color.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 22.06.2025.
//

import Foundation
import SwiftUI

extension Color {
    static var customPurple: Color {
        colorSchemeAdaptive(light: "#6F5DB7", dark: "#9C8CFF")
    }
    
    static var customGreen: Color {
        colorSchemeAdaptive(light: "#2AE881", dark: "#1DD68C")
    }
    
    static var customLightGreen: Color {
        colorSchemeAdaptive(light: "#D4FAE6", dark: "#1E3C2D")
    }
    
    static var customGray: Color {
        colorSchemeAdaptive(light: "#8080808C", dark: "#CCCCCC33")
    }
    
    static var backgroundScreenColor: Color {
        colorSchemeAdaptive(light: "#F2F2F7", dark: "#1C1C1E")
    }
    
    static var searchBarColor: Color {
        colorSchemeAdaptive(light: "#7878801F", dark: "#FFFFFF14")
    }
    
    static var subTitleColor: Color {
        colorSchemeAdaptive(light: "#3C3C4399", dark: "#EBEBF599")
    }
    
    // MARK: - Точка входа
    private static func colorSchemeAdaptive(light: String, dark: String) -> Color {
        ColorSchemeManager.isDarkMode ? Color(hex: dark) : Color(hex: light)
    }
}


//Добавление нового конструктора
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
