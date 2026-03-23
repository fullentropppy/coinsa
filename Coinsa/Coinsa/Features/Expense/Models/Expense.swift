//
//  Expense.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.02.2026.
//

import Foundation
import SwiftData

@Model
class Expense {
    // MARK: - Stored Properties
    
    var date: Date
    var amountBase: Double
    var rateBaseToLocal: Double
    var category: ExpenseCategory
    var location: Location
    var comment: String?

    // MARK: - Initialization
    
    init(
        date: Date = .now,
        amountBase: Double,
        rateBaseToLocal: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String? = nil
    ) {
        self.date = date
        self.amountBase = amountBase
        self.rateBaseToLocal = rateBaseToLocal
        self.category = category
        self.location = location
        self.comment = comment
    }
}
