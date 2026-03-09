//
//  ExpenseCategory+SymbolName.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension ExpenseCategory {
    var symbolName: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car"
        case .activities: "sparkles.2"
        case .shopping: "bag"
        case .medicine: "pills"
        case .other: "circle.grid.2x2"
        }
    }
}
