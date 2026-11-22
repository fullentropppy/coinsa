//
//  Expense+Badge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Expense: TypeBadgeProviding {
    // MARK: - Свойства

    /// Стиль бейджа для траты (иконка с акцентным цветом).
    static var badgeStyle: Badge.Style {
        .icon(icon: secondaryIcon, fill: accentColor)
    }
}
