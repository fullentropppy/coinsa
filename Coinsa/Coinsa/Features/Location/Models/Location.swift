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
    var locationCurrencyCode: String
    var exchangeRateLocationToBaseCurrency: Double
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
        locationCurrencyCode: String,
        exchangeRateLocationToBaseCurrency: Double,
        trip: Trip,
        budgets: [Budget] = [],
        expenses: [Expense] = []
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locationCurrencyCode = locationCurrencyCode
        self.exchangeRateLocationToBaseCurrency = exchangeRateLocationToBaseCurrency
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
}
