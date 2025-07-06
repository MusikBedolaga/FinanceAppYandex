//
//  AnalysisView.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 05.07.2025.
//

import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    var direction: Direction
    
    func makeUIViewController(context: Context) -> AnalysisVC {
        return AnalysisVC(direction: direction)
    }
    
    func updateUIViewController(_ uiViewController: AnalysisVC, context: Context) {}
}

