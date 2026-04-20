//
//  EventStatus+Badge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension EventStatus: ValueBadgeProviding {    
    var badgeStyle: BadgeView.Style {
        .title(title: localizedResource, fill: accentColor)
    }
}
