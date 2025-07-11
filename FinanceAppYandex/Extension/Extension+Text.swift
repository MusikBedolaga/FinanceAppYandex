//
//  Extension+Text.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 14.06.2025.
//

import Foundation
import SwiftUI

extension Text {
    static func makeScreenTitle(titleText: String) -> some View {
        Text(titleText)
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.black)
    }
    
    static func makeSubTitle(subTitle: String) -> some View {
        Text(subTitle)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color.subTitleColor)
    }
}
