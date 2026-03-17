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
    let baseCurrencyOption: CurrencyOption
    let localCurrencyOption: CurrencyOption

    // MARK: - Computed Properties

    var headerData: ExpenseDetailHeaderData {
        ExpenseDetailHeaderData(
            category: expense.category,
            date: expense.date,
            amount: expense.amountInLocationCurrency,
            localCurrencyOption: localCurrencyOption
        )
    }

    // MARK: - Initialization

    init(expense: Expense, baseCurrencyOption: CurrencyOption) {
        self.expense = expense
        self.baseCurrencyOption = baseCurrencyOption
        self.localCurrencyOption = CurrencyOption.from(code: expense.location.currencyCode)
    }
}

struct ExpenseDetailHeaderData {
    let category: ExpenseCategory
    let date: Date
    let amount: Double
    let localCurrencyOption: CurrencyOption
}
