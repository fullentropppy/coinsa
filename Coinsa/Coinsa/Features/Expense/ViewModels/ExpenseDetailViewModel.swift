//
//  ExpenseDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.03.2026.
//

import Foundation

struct ExpenseDetailViewModel {
    // MARK: - Stored Properties

    let expense: Expense
    let baseCurrency: Currency
    let localCurrency: Currency

    // MARK: - Computed Properties

    var headerData: ExpenseDetailHeaderData {
        ExpenseDetailHeaderData(
            category: expense.category,
            date: expense.date,
            amount: expense.amountInLocationCurrency,
            localCurrency: localCurrency
        )
    }

    // MARK: - Initialization

    init(expense: Expense, baseCurrency: Currency) {
        self.expense = expense
        self.baseCurrency = baseCurrency
        self.localCurrency = Currency.from(code: expense.location.currencyCode)
    }
}

struct ExpenseDetailHeaderData {
    let category: ExpenseCategory
    let date: Date
    let amount: Double
    let localCurrency: Currency
}
