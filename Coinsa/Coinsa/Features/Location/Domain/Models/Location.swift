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
    var selectedTimeZoneIdentifier: String
    var localCurrencyCode: String
    var rateLocalToBase: Double
    var exchangeAdjustment: Double
    var trip: Trip
    var budgets: [ExpenseCategory: Double]
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.location)
    var expenses: [Expense]

    // MARK: - Инициализация
    
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        selectedTimeZoneIdentifier: String,
        localCurrencyCode: String,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        trip: Trip,
        budgets: [ExpenseCategory: Double] = [:],
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
        self.selectedTimeZoneIdentifier = selectedTimeZoneIdentifier
        self.localCurrencyCode = localCurrencyCode
        self.rateLocalToBase = rateLocalToBase
        self.exchangeAdjustment = exchangeAdjustment
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
}
