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
        amountInLocationCurrency: Double,
        exchangeRateLocationToBaseCurrency: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String?
    ) {
        let expense = Expense(
            date: date,
            amountInLocationCurrency: max(0, amountInLocationCurrency),
            exchangeRateLocationToBaseCurrency: max(0, exchangeRateLocationToBaseCurrency),
            category: category,
            location: location,
            comment: comment
        )
        context.insert(expense)
    }

    func update(
        _ expense: Expense,
        date: Date,
        amountInLocationCurrency: Double,
        exchangeRateLocationToBaseCurrency: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.amountInLocationCurrency = max(0, amountInLocationCurrency)
        expense.rateToBaseCurrency = max(0, exchangeRateLocationToBaseCurrency)
        expense.category = category
        expense.comment = comment
    }

    func delete(_ expense: Expense) {
        context.delete(expense)
    }
}
