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
    var amountInLocationCurrency: Double
    var rateToBaseCurrency: Double
    var category: ExpenseCategory
    var location: Location
    var comment: String?

    // MARK: - Computed Properties
    
    var amountInBaseCurrency: Double {
        amountInLocationCurrency * rateToBaseCurrency
    }

    // MARK: - Initialization
    
    init(
        date: Date = .now,
        amountInLocationCurrency: Double,
        exchangeRateLocationToBaseCurrency: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String? = nil
    ) {
        self.date = date
        self.amountInLocationCurrency = amountInLocationCurrency
        self.rateToBaseCurrency = exchangeRateLocationToBaseCurrency
        self.category = category
        self.location = location
        self.comment = comment
    }
}
