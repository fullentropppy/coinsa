//
//  Location+TypeBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension Location: TypeBadgeProviding {
    static var badgeColor: Color { .pink }
    static var badgeIcon: String? { "mappin.and.ellipse" }
}
