//
//  ValueBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol ValueBadgeProviding {
    // MARK: - Свойства
    
    var badgeColor: Color { get }
    var badgeIcon: String? { get }
    var badgeTitle: LocalizedStringResource? { get }
    
    // MARK: - Методы
    
    func makeBadge() -> BadgeView
    func makeDot() -> DotView
}

// MARK: - Стандартная реализация

extension ValueBadgeProviding {
    // MARK: - Свойства со значениями по умолчанию
    
    var badgeIcon: String? { nil }
    var badgeTitle: LocalizedStringResource? { nil }
    
    // MARK: - Свойства с безопасным извлечением
    
    var safeBadgeIcon: String { badgeIcon ?? "" }
    var safeBadgeTitle: LocalizedStringResource { badgeTitle ?? "" }
    
    // MARK: - Методы
    
    func makeBadge() -> BadgeView {
        BadgeView(
            fillColor: badgeColor,
            icon: badgeIcon,
            title: badgeTitle
        )
    }
    
    func makeDot() -> DotView {
        DotView(badgeColor)
    }
}
