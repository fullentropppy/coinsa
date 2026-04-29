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
    var createdAt: Date
    var updatedAt: Date
    
    var name: String
    var startDate: Date
    var endDate: Date
    var majorTimeZone: MajorTimeZone
    var localCurrency: Currency
    var rateLocalToBase: Double
    var exchangeAdjustment: Double
    var trip: Trip

    @Relationship(deleteRule: .cascade, inverse: \Budget.location)
    var budgets: [Budget]
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.location)
    var expenses: [Expense]

    // MARK: - Инициализация
    
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        majorTimeZone: MajorTimeZone,
        localCurrency: Currency,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        trip: Trip,
        budgets: [Budget] = [],
        expenses: [Expense] = [],
        createdAt: Date,
        updatedAt: Date,
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.majorTimeZone = majorTimeZone
        self.localCurrency = localCurrency
        self.rateLocalToBase = rateLocalToBase
        self.exchangeAdjustment = exchangeAdjustment
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
}
