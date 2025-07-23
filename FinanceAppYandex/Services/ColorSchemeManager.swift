import Foundation
import UIKit

enum ColorSchemeManager {
    static var isDarkMode: Bool {
        UITraitCollection.current.userInterfaceStyle == .dark
    }
}

