//
//  TypeBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol TypeBadgeProviding: TypeVisualRepresentable {
    // MARK: - Свойства
    
    static var badgeStyle: BadgeView.Style { get }
    
    // MARK: - Методы
    
    static func makeBadge() -> BadgeView
    static func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension TypeBadgeProviding {
    static func makeBadge() -> BadgeView {
        BadgeView(style: badgeStyle)
    }
    
    static func makeDot() -> DotView {
        DotView(accentColor)
    }
}

