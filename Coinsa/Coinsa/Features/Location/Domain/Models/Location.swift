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
    
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var name: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var timeZoneID: String = ""
    var localCurrencyCode: String = ""
    var rateLocalToBase: Double = 0
    var exchangeAdjustment: Double = 0
    var trip: Trip? = nil

    @Relationship(deleteRule: .cascade, inverse: \Budget.location)
    var budgets: [Budget]?
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.location)
    var expenses: [Expense]?

    // MARK: - Инициализация
    
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        timeZoneID: String,
        localCurrencyCode: String,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        trip: Trip,
        budgets: [Budget],
        expenses: [Expense],
        createdAt: Date,
        updatedAt: Date,
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.timeZoneID = timeZoneID
        self.localCurrencyCode = localCurrencyCode
        self.rateLocalToBase = rateLocalToBase
        self.exchangeAdjustment = exchangeAdjustment
        self.trip = trip
        self.budgets = budgets
        self.expenses = expenses
    }
}
