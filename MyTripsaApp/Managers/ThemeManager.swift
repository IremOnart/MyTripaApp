//
//  Untitled.swift
//  MyTripsaApp
//
//  Created by İrem Onart on 2.01.2025.
//

import Foundation
import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme: Theme {
        get {
            Theme(rawValue: UserDefaults.standard.string(forKey: "appTheme") ?? "system") ?? .system
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "appTheme")
            applyTheme(theme: newValue)
        }
    }
    
    func applyTheme(theme: Theme) {
        switch theme {
        case .light:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        case .dark:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        case .system:
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        }
    }
}
