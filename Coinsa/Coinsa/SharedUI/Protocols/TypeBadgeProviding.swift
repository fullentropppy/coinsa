//
//  TypeBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

/// Протокол для типов, предоставляющих бейдж и точку с визуальным стилем.
protocol TypeBadgeProviding: TypeVisualRepresentable {
    // MARK: - Свойства
    
    /// Стиль бейджа для отображения.
    static var badgeStyle: BadgeView.Style { get }
    
    // MARK: - Методы
    
    /// Создает представление бейджа.
    static func makeBadge() -> BadgeView
    
    /// Создает представление точки.
    static func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension TypeBadgeProviding {
    /// Создает бейдж на основе свойства `badgeStyle`.
    static func makeBadge() -> BadgeView {
        BadgeView(style: badgeStyle)
    }
    
    /// Создает точку с акцентным цветом типа.
    static func makeDot() -> DotView {
        DotView(accentColor)
    }
}

