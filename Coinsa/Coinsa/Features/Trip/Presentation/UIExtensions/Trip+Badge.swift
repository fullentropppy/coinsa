//
//  TypeBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Trip: TypeBadgeProviding {
    /// Стиль бейджа для поездки (иконка с акцентным цветом).
    static var badgeStyle: BadgeView.Style {
        .icon(icon: secondaryIcon, fill: accentColor)
    }
}
