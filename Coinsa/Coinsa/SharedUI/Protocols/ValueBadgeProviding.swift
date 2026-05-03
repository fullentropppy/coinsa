//
//  ValueBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

/// Протокол для значений, предоставляющих бейдж и точку с визуальным стилем.
protocol ValueBadgeProviding: ValueVisualRepresentable {
    // MARK: - Свойства
    
    /// Стиль бейджа для отображения.
    var badgeStyle: BadgeView.Style { get }
    
    // MARK: - Методы
    
    /// Создает представление бейджа.
    func makeBadge() -> BadgeView
    
    /// Создает представление точки.
    func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension ValueBadgeProviding {
    /// Создает бейдж на основе свойства `badgeStyle`.
    func makeBadge() -> BadgeView {
        BadgeView(style: badgeStyle)
    }
    
    /// Создает точку с акцентным цветом типа.
    func makeDot() -> DotView {
        DotView(accentColor)
    }
}
