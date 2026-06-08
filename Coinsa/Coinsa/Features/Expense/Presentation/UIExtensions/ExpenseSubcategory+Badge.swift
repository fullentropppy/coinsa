//
//  ExpenseSubcategory+Badge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.06.2026.
//

import SwiftUI

extension ExpenseSubcategory: ValueBadgeProviding {
    /// Стиль бейджа для подкатегории траты (иконка + текст, заливка акцентным цветом родительской категории).
    var badgeStyle: BadgeView.Style {
        .combined(icon: secondaryIcon, badge: localizedResource, fill: accentColor)
    }
}
