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
    // MARK: - Stored properties
    
    var date: Date
    var amountInLocationCurrency: Double
    var exchangeRateLocationToBaseCurrency: Double
    var category: ExpenseCategory
    var location: Location
    var comment: String?
    
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
        self.exchangeRateLocationToBaseCurrency = exchangeRateLocationToBaseCurrency
        self.category = category
        self.location = location
        self.comment = comment
    }
}
