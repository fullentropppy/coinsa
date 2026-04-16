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
    // MARK: - Stored Properties
    
    @Attribute(.unique)
    var id: UUID
    
    var date: Date
    var baseAmount: Double
    var rateLocalToBase: Double
    var paymentMethod: PaymentMethod
    var exchangeAdjustmentPercentage: Double
    var category: ExpenseCategory
    var location: Location
    var comment: String?

    // MARK: - Initialization
    
    init(
        date: Date = .now,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustmentPercentage: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.baseAmount = baseAmount
        self.rateLocalToBase = rateLocalToBase
        self.paymentMethod = paymentMethod
        self.exchangeAdjustmentPercentage = exchangeAdjustmentPercentage
        self.category = category
        self.location = location
        self.comment = comment
    }
}
