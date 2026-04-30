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
    
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var date: Date = Date()
    var baseAmount: Double = 0
    var rateLocalToBase: Double = 0
    var paymentMethodRaw: String = ""
    var exchangeAdjustment: Double = 0
    var categoryRaw: String = ""
    var location: Location?
    var comment: String?

    // MARK: - Инициализация
    
    init(
        id: UUID,
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethodRaw: String,
        exchangeAdjustment: Double,
        categoryRaw: String ,
        location: Location,
        comment: String?,
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
