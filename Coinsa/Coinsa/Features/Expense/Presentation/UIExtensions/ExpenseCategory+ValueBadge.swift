//
//  ExpenseCategory+ValueBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension ExpenseCategory: ValueBadgeProviding {
    var badgeColor: Color {
        switch self {
        case .food: .mint
        case .transport: .blue
        case .activity: .yellow
        case .shopping: .red
        case .medicine: .cyan
        case .other: .brown
        }
    }
    
    var badgeIcon: String? {
        switch self {
        case .food: "fork.knife"
        case .transport: "car"
        case .activity: "sparkles.2"
        case .shopping: "bag"
        case .medicine: "pills"
        case .other: "circle.grid.2x2"
        }
    }
    
    var badgeTitle: LocalizedStringResource? {
        self.localizedResource
    }
}

