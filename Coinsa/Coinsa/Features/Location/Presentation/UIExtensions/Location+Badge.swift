//
//  Location+Badge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Location: TypeBadgeProviding {
    static var badgeStyle: BadgeView.Style {
        .icon(icon: secondaryIcon, fill: accentColor)
    }
}
