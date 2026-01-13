//
//  StyleModel.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import UIKit

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Светлая"
        case .dark:
            return "Тёмная"
        case .system:
            return "Системная"
        }
    }
}

struct StyleModel {
    // Фоновые цвета
    let backgroundColor: UIColor
    let secondaryBackgroundColor: UIColor
    
    // Цвета градиента
    let gradientStartColor: UIColor
    let gradientEndColor: UIColor
    
    // Текстовые цвета
    let primaryTextColor: UIColor
    let secondaryTextColor: UIColor
    
    // Акцентные цвета
    let accentColor: UIColor
    let tintColor: UIColor
    
    // Цвета для элементов интерфейса
    let separatorColor: UIColor
    let borderColor: UIColor
    
    // Цвет для иконок
    let iconColor: UIColor
    
    static func style(for theme: AppTheme) -> StyleModel {
        switch theme {
        case .light:
            return StyleModel(
                backgroundColor: UIColor(hex: "FFFFFF"),
                secondaryBackgroundColor: UIColor(hex: "F5F5F5"),
                gradientStartColor: UIColor(hex: "FFFFFF"),
                gradientEndColor: UIColor(hex: "FF4500"),
                primaryTextColor: UIColor(hex: "000000"),
                secondaryTextColor: UIColor(hex: "666666"),
                accentColor: UIColor(hex: "FF4500"),
                tintColor: UIColor(hex: "FF6347"),
                separatorColor: UIColor(hex: "E0E0E0"),
                borderColor: UIColor(hex: "CCCCCC"),
                iconColor: UIColor(hex: "000000")
            )
        case .dark:
            return StyleModel(
                backgroundColor: UIColor(hex: "1A1A2E"),
                secondaryBackgroundColor: UIColor(hex: "16213E"),
                gradientStartColor: UIColor(hex: "1A1A2E"),
                gradientEndColor: UIColor(hex: "FF4500"),
                primaryTextColor: UIColor(hex: "FFFFFF"),
                secondaryTextColor: UIColor(hex: "CCCCCC"),
                accentColor: UIColor(hex: "FF4500"),
                tintColor: UIColor(hex: "FF6347"),
                separatorColor: UIColor(hex: "333333"),
                borderColor: UIColor(hex: "444444"),
                iconColor: UIColor(hex: "000000")
            )
        case .system:
            return StyleModel(
                backgroundColor: UIColor.systemBackground,
                secondaryBackgroundColor: UIColor.secondarySystemBackground,
                gradientStartColor: UIColor.systemGray5,
                gradientEndColor: UIColor.systemGray3,
                primaryTextColor: UIColor.label,
                secondaryTextColor: UIColor.secondaryLabel,
                accentColor: UIColor.systemOrange,
                tintColor: UIColor.systemOrange,
                separatorColor: UIColor.separator,
                borderColor: UIColor.separator,
                iconColor: UIColor.label
            )
        }
    }
    
    static func currentStyle(for theme: AppTheme? = nil) -> StyleModel {
        let currentTheme = theme ?? DesignManager.shared.currentTheme
        let effectiveTheme: AppTheme
        
        if currentTheme == .system {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                effectiveTheme = window.traitCollection.userInterfaceStyle == .dark ? .dark : .light
            } else {
                effectiveTheme = .dark
            }
        } else {
            effectiveTheme = currentTheme
        }
        
        return style(for: effectiveTheme)
    }
}
