//
//  DesignManager.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

final class DesignManager {
    static let shared = DesignManager()
    
    private let themeKey = "AppTheme"
    
    var currentTheme: AppTheme {
        get {
            if let themeString = UserDefaults.standard.string(forKey: themeKey),
               let theme = AppTheme(rawValue: themeString) {
                return theme
            }
            return .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
        }
    }
    
    private init() {
        applyTheme(currentTheme)
    }
    
    func applyTheme(_ theme: AppTheme) {
        // Применяем тему ко всем окнам
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                if theme == .system {
                    window.overrideUserInterfaceStyle = .unspecified
                } else {
                    window.overrideUserInterfaceStyle = theme == .dark ? .dark : .light
                }
            }
        }
        
        // Отправляем уведомление об изменении темы
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
    
    func getCurrentStyle() -> StyleModel {
        return StyleModel.currentStyle()
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
