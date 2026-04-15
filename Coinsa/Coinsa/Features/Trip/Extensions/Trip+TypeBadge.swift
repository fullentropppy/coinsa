//
//  Trip+TypeBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Trip: TypeBadgeProviding {
    static var badgeColor: Color { .indigo }
    static var badgeIcon: String? { "suitcase.fill" }
}
