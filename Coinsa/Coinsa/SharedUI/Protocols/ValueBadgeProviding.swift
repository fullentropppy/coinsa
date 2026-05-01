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
    
    /// Создаёт представление бейджа.
    func makeBadge() -> BadgeView
    
    /// Создаёт представление точки.
    func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension ValueBadgeProviding {
    /// Создаёт бейдж на основе свойства `badgeStyle`.
    func makeBadge() -> BadgeView {
        BadgeView(style: badgeStyle)
    }
    
    /// Создаёт точку с акцентным цветом типа.
    func makeDot() -> DotView {
        DotView(accentColor)
    }
}
