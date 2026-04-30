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
    // MARK: - Свойства
    
    @Attribute(.unique)
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    var date: Date
    var baseAmount: Double
    var rateLocalToBase: Double
    var paymentMethodRaw: String
    var exchangeAdjustment: Double
    var categoryRaw: String
    var location: Location
    var comment: String?

    // MARK: - Инициализация
    
    init(
        id: UUID,
        date: Date = .now,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethodRaw: String,
        exchangeAdjustment: Double,
        categoryRaw: String,
        location: Location,
        comment: String? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.date = date
        self.baseAmount = baseAmount
        self.rateLocalToBase = rateLocalToBase
        self.paymentMethodRaw = paymentMethodRaw
        self.exchangeAdjustment = exchangeAdjustment
        self.categoryRaw = categoryRaw
        self.location = location
        self.comment = comment
    }
}
