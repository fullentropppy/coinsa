//
//  ExpenseCategory+Label.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import SwiftUI

extension ExpenseCategory {
    var labelIcon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car"
        case .activity: "sparkles.2"
        case .shopping: "bag"
        case .medicine: "pills"
        case .other: "circle.grid.2x2"
        }
    }
    
    var badgeIcon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .activity: "sparkles.2"
        case .shopping: "bag.fill"
        case .medicine: "pills.fill"
        case .other: "circle.grid.2x2.fill"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .food: .mint
        case .transport: .blue
        case .activity: .purple
        case .shopping: .pink
        case .medicine: .red
        case .other: .gray
        }
    }
}
