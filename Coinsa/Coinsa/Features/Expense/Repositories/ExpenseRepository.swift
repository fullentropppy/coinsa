//
//  ExpenseRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.03.2026.
//

import Foundation
import SwiftData

@MainActor
struct ExpenseRepository {
    // MARK: - Stored Properties

    let context: ModelContext

    // MARK: - Public Methods

    func add(
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustmentPercentage: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String?
    ) {
        let expense = Expense(
            date: date,
            baseAmount: normalizeBaseAmount(baseAmount),
            rateLocalToBase: normalizeRateLocalToBase(rateLocalToBase),
            paymentMethod: paymentMethod,
            exchangeAdjustmentPercentage: normalizeExchangeAdjustmentPercentage(exchangeAdjustmentPercentage),
            category: category,
            location: location,
            comment: normalizeComment(comment)
        )
        context.insert(expense)
        try? context.save()
    }

    func update(
        _ expense: Expense,
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustmentPercentage: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.baseAmount = normalizeBaseAmount(baseAmount)
        expense.rateLocalToBase = normalizeRateLocalToBase(rateLocalToBase)
        expense.paymentMethod = paymentMethod
        expense.exchangeAdjustmentPercentage = normalizeExchangeAdjustmentPercentage(exchangeAdjustmentPercentage)
        expense.category = category
        expense.comment = normalizeComment(comment)
        try? context.save()
    }

    func delete(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
    }
    
    // MARK: - Private Methods
    
    private func normalizeBaseAmount(_ amount: Double) -> Double {
        amount > 0 ? amount.rounded(to: 2) : 0
    }
    
    private func normalizeRateLocalToBase(_ rate: Double) -> Double {
        rate > 0 ? rate.rounded(to: 4) : 0
    }
    
    private func normalizeExchangeAdjustmentPercentage(_ percentage: Double) -> Double {
        max(0, percentage)
    }
    
    private func normalizeComment(_ comment: String?) -> String? {
        comment == nil ? nil : comment?.trimmed
    }
}
