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
        amountInLocalCurrency: Double,
        rateToBaseCurrency: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String?
    ) {
        let expense = Expense(
            date: date,
            amountInLocalCurrency: max(0, amountInLocalCurrency),
            rateToBaseCurrency: max(0, rateToBaseCurrency),
            category: category,
            location: location,
            comment: comment
        )
        context.insert(expense)
    }

    func update(
        _ expense: Expense,
        date: Date,
        amountInLocalCurrency: Double,
        rateToBaseCurrency: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.amountInLocalCurrency = max(0, amountInLocalCurrency)
        expense.rateToBaseCurrency = max(0, rateToBaseCurrency)
        expense.category = category
        expense.comment = comment
    }

    func delete(_ expense: Expense) {
        context.delete(expense)
    }
}
