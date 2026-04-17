//
//  Location.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Location: DateRangeProviding {
    // MARK: - Свойства
    
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    var startDate: Date
    var endDate: Date
    var localCurrencyCode: String
    var rateLocalToBase: Double
    var exchangeAdjustment: Double
    var trip: Trip
    
    @Relationship(deleteRule: .cascade, inverse: \Budget.location)
    var budgets: [Budget]
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.location)
    var expenses: [Expense]

    // MARK: - Инициализация
    
    init(
        name: String,
        startDate: Date,
        endDate: Date,
        localCurrencyCode: String,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
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
        self.exchangeAdjustment = exchangeAdjustment
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
}
