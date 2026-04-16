//
//  TypeBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol TypeBadgeProviding {
    // MARK: - Свойства
    
    static var badgeColor: Color { get }
    static var badgeIcon: String? { get }
    static var badgeTitle: LocalizedStringResource? { get }
    
    // MARK: - Методы
    
    static func makeBadge() -> BadgeView
    static func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension TypeBadgeProviding {
    // MARK: - Свойства со значениями по умолчанию
    
    static var badgeIcon: String? { nil }
    static var badgeTitle: LocalizedStringResource? { nil }
    
    // MARK: - Свойства с безопасным извлечением
    
    static var safeBadgeIcon: String { badgeIcon ?? "" }
    static var safeBadgeTitle: LocalizedStringResource { badgeTitle ?? "" }
    
    // MARK: - Методы
    
    static func makeBadge() -> BadgeView {
        BadgeView(
            fillColor: badgeColor,
            icon: badgeIcon,
            title: badgeTitle
        )
    }
    
    static func makeDot() -> DotView {
        DotView(badgeColor)
    }
}

