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
    var baseAmount: Double
    var rateLocalToBase: Double
    var category: ExpenseCategory
    var location: Location
    var comment: String?

    // MARK: - Initialization
    
    init(
        date: Date = .now,
        baseAmount: Double,
        rateLocalToBase: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String? = nil
    ) {
        self.date = date
        self.baseAmount = baseAmount
        self.rateLocalToBase = rateLocalToBase
        self.category = category
        self.location = location
        self.comment = comment
    }
}
