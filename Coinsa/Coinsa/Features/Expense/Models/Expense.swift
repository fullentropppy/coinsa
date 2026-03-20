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
    var amountInLocalCurrency: Double
    var rateToBaseCurrency: Double
    var category: ExpenseCategory
    var location: Location
    var comment: String?

    // MARK: - Computed Properties
    
    var amountInBaseCurrency: Double {
        amountInLocalCurrency * rateToBaseCurrency
    }

    // MARK: - Initialization
    
    init(
        date: Date = .now,
        amountInLocalCurrency: Double,
        rateToBaseCurrency: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String? = nil
    ) {
        self.date = date
        self.amountInLocalCurrency = amountInLocalCurrency
        self.rateToBaseCurrency = rateToBaseCurrency
        self.category = category
        self.location = location
        self.comment = comment
    }
}
