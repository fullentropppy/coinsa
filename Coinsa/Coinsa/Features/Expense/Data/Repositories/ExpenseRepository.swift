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
        let expense = Expense(
            date: date,
            baseAmount: baseAmount.nonNegative,
            rateLocalToBase: rateLocalToBase.nonNegative,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment.nonNegative,
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
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.baseAmount = baseAmount.nonNegative
        expense.rateLocalToBase = rateLocalToBase.nonNegative
        expense.paymentMethod = paymentMethod
        expense.exchangeAdjustment = exchangeAdjustment.nonNegative
        expense.category = category
        expense.comment = normalizeComment(comment)
        expense.updatedAt = Date()
        try? context.save()
    }

    func delete(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
    }
    
    // MARK: - Нормализация значений

    private func normalizeComment(_ comment: String?) -> String? {
        comment == nil ? nil : comment?.trimmed
    }
}
