//
//  TypeBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol TypeBadgeProviding {
    static var badgeColor: Color { get }
    static var badgeIcon: String? { get }
    static var badgeTitle: LocalizedStringResource? { get }
}

// MARK: - Стандартная реализация

extension TypeBadgeProviding {
    // MARK: - Свойства
    
    static var badgeIcon: String? { nil }
    static var badgeTitle: LocalizedStringResource? { nil }
    
    // MARK: - Методы
    
    static func makeBadge() -> some View {
        BadgeView(
            fillColor: badgeColor,
            icon: badgeIcon,
            title: badgeTitle
        )
    }
    
    static func makeDot() -> some View {
        DotView(badgeColor)
    }
}

