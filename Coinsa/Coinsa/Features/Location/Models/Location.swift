//
//  Location.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Location: DateRangeProviding, EventStatusProviding {
    // MARK: - Stored Properties
    
    var name: String
    var startDate: Date
    var endDate: Date
    var currencyCode: String
    var rateToBaseCurrency: Double
    var trip: Trip
    
    @Relationship(deleteRule: .cascade, inverse: \Budget.location)
    var budgets: [Budget]
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.location)
    var expenses: [Expense]

    // MARK: - Initialization
    
    init(
        name: String,
        startDate: Date,
        endDate: Date,
        currencyCode: String,
        rateToBaseCurrency: Double,
        trip: Trip,
        budgets: [Budget] = [],
        expenses: [Expense] = []
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.currencyCode = currencyCode
        self.rateToBaseCurrency = rateToBaseCurrency
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
    
    // MARK: - Public Methods

    func calculatePlannedAmount(inBaseCurrency: Bool) -> Double {
        budgets.reduce(0) {
            let exchangeRate = inBaseCurrency ? 1 : rateToBaseCurrency
            return $0 + $1.amountInBaseCurrency * exchangeRate
        }
    }

    func calculateActualAmount(inBaseCurrency: Bool) -> Double {
        expenses.reduce(0) {
            let exchangeRate = inBaseCurrency ? 1 : $1.rateToBaseCurrency
            return $0 + $1.amountInLocalCurrency * exchangeRate
        }
    }
}
