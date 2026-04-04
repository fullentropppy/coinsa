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
        localAmount: Double,
        rateLocalToBase: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String?
    ) {
        let expense = Expense(
            date: date,
            baseAmount: max(0, localAmount),
            rateLocalToBase: max(0, rateLocalToBase),
            category: category,
            location: location,
            comment: comment
        )
        context.insert(expense)
        try? context.save()
    }

    func update(
        _ expense: Expense,
        date: Date,
        localAmount: Double,
        rateLocalToBase: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.baseAmount = max(0, localAmount)
        expense.rateLocalToBase = max(0, rateLocalToBase)
        expense.category = category
        expense.comment = comment
        try? context.save()
    }

    func delete(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
    }
}
