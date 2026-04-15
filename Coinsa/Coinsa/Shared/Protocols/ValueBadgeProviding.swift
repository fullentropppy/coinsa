//
//  ValueBadgeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

// MARK: - Протокол

protocol ValueBadgeProviding {
    var badgeColor: Color { get }
    var badgeIcon: String? { get }
    var badgeTitle: LocalizedStringResource? { get }
}

// MARK: - Стандартная реализация

extension ValueBadgeProviding {
    // MARK: - Свойства
    
    var badgeIcon: String? { nil }
    var badgeTitle: LocalizedStringResource? { nil }
    
    // MARK: - Методы
    
    func makeBadge() -> some View {
        BadgeView(
            fillColor: badgeColor,
            icon: badgeIcon,
            title: badgeTitle
        )
    }
    
    func makeDot() -> some View {
        DotView(badgeColor)
    }
}
