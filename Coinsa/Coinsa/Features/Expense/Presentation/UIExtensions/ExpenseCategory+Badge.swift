//
//  ExpenseCategory+Badge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension ExpenseCategory: ValueBadgeProviding {
    var badgeStyle: BadgeView.Style {
        .combined(icon: secondaryIcon, badge: localizedResource, fill: accentColor)
    }
}

