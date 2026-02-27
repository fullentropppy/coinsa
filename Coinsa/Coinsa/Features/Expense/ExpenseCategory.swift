//
//  ExpenseCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation

enum ExpenseCategory: String {
    // MARK: - Cases
    
    case food = "expense.category.food"
    case transport = "expense.category.transport"
    case activities = "expense.category.entertainment"
    case shopping = "expense.category.shopping"
    case medicine = "expense.category.medicine"
    case other = "expense.category.other"
    
    // MARK: - Properties
    
    var localized: String {
        String(localized: String.LocalizationValue(rawValue))
    }
    
    var sfSymbolName: String {
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
