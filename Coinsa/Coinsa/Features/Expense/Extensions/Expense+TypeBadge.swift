//
//  Expense+TypeBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Expense: TypeBadgeProviding {
    static var badgeColor: Color { .orange }
    static var badgeIcon: String? { "cart.fill" }
}
