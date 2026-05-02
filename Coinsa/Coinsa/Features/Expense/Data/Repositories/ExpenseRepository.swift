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
    // MARK: - Свойства

    let context: ModelContext

    // MARK: - Операции с хранилищем

    func add(
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String?
    ) {
        let now = Date()
        
        let expense = Expense(
            id: UUID(),
            date: date,
            baseAmount: normalizedAmount(baseAmount),
            rateLocalToBase: normalizedRateLocalToBase(rateLocalToBase),
            paymentMethodRaw: paymentMethod.rawValue,
            exchangeAdjustment: normalizedExchangeAdjustment(exchangeAdjustment),
            categoryRaw: category.rawValue,
            location: location,
            comment: normalizedComment(comment),
            createdAt: now,
            updatedAt: now
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
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.baseAmount = normalizedAmount(baseAmount)
        expense.rateLocalToBase = normalizedRateLocalToBase(rateLocalToBase)
        expense.paymentMethodRaw = paymentMethod.rawValue
        expense.exchangeAdjustment = normalizedExchangeAdjustment(exchangeAdjustment)
        expense.categoryRaw = category.rawValue
        expense.comment = normalizedComment(comment)
        expense.updatedAt = Date()
        try? context.save()
    }

    func delete(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
    }
    
    // MARK: - Нормализация значений

    private func normalizedAmount(_ amount: Double) -> Double {
        amount.nonNegative
    }
    
    private func normalizedRateLocalToBase(_ rate: Double) -> Double {
        rate.nonNegative
    }
    
    private func normalizedExchangeAdjustment(_ adjustment: Double) -> Double {
        adjustment.nonNegative
    }
    
    private func normalizedComment(_ comment: String?) -> String? {
        if let comment, !comment.isBlank {
            comment.trimmed
        } else {
            nil
        }
    }
}
