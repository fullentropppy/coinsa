//
//  ExpenseViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ExpenseViewModel {
    // MARK: - Stored Properties

    private let expense: Expense?

    let location: Location
    let baseCurrencyOption: CurrencyOption
    let localCurrencyOption: CurrencyOption

    var category: ExpenseCategory
    var date: Date
    var amountInLocationCurrency: Double
    var rateToBaseCurrency: Double
    var comment: String

    // MARK: - Computed Properties

    var isEditing: Bool {
        expense != nil
    }

    var expenseToEdit: Expense? {
        expense
    }

    var navigationTitle: String {
        String(
            localized: isEditing
                ? "expense.editing.navigationTitle.editing"
                : "expense.editing.navigationTitle.creating"
        )
    }

    var amountInBaseCurrency: Double {
        let normalizedAmount = max(0, amountInLocationCurrency)
        let normalizedRate = max(0, rateToBaseCurrency)
        return normalizedAmount * normalizedRate
    }

    // MARK: - Initialization

    init(location: Location, expense: Expense?, baseCurrencyOption: CurrencyOption) {
        self.expense = expense
        self.location = expense?.location ?? location
        self.baseCurrencyOption = baseCurrencyOption
        self.localCurrencyOption = CurrencyOption.from(code: self.location.currencyCode)

        if let expense {
            category = expense.category
            date = expense.date
            amountInLocationCurrency = expense.amountInLocationCurrency
            rateToBaseCurrency = expense.rateToBaseCurrency
            comment = expense.comment ?? ""
        } else {
            category = .food
            date = .now
            amountInLocationCurrency = 0
            rateToBaseCurrency = self.location.rateToBaseCurrency
            comment = ""
        }
    }

    // MARK: - Public Methods

    func save(using repository: ExpenseRepository) {
        let normalizedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let commentValue = normalizedComment.isEmpty ? nil : normalizedComment

        if let expense {
            repository.update(
                expense,
                date: date,
                amountInLocationCurrency: amountInLocationCurrency,
                exchangeRateLocationToBaseCurrency: rateToBaseCurrency,
                category: category,
                comment: commentValue
            )
        } else {
            repository.add(
                date: date,
                amountInLocationCurrency: amountInLocationCurrency,
                exchangeRateLocationToBaseCurrency: rateToBaseCurrency,
                category: category,
                location: location,
                comment: commentValue
            )
        }
    }
}
