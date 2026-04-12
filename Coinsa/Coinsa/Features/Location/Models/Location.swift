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
    
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    var startDate: Date
    var endDate: Date
    var localCurrencyCode: String
    var rateLocalToBase: Double
    var exchangeAdjustmentPercentage: Double
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
        localCurrencyCode: String,
        rateLocalToBase: Double,
        exchangeAdjustmentPercentage: Double,
        trip: Trip,
        budgets: [Budget] = [],
        expenses: [Expense] = []
    ) {
        self.id = UUID()
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.localCurrencyCode = localCurrencyCode
        self.rateLocalToBase = rateLocalToBase
        self.exchangeAdjustmentPercentage = exchangeAdjustmentPercentage
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
}
