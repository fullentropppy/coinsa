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
        case .transport: "car.fill"
        case .activity: "sparkles.2"
        case .shopping: "bag.fill"
        case .medicine: "pills.fill"
        case .other: "circle.grid.2x2.fill"
        }
    }
    
    var badgeTitle: LocalizedStringResource? {
        self.localizedResource
    }
}

