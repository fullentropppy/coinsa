//
//  ValueBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol ValueBadgeProviding: ValueVisualRepresentable {
    // MARK: - Свойства
    
    var badgeStyle: BadgeView.Style { get }
    
    // MARK: - Методы
    
    func makeBadge() -> BadgeView
    func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension ValueBadgeProviding {
    func makeBadge() -> BadgeView {
        BadgeView(style: badgeStyle)
    }
    
    func makeDot() -> DotView {
        DotView(accentColor)
    }
}
