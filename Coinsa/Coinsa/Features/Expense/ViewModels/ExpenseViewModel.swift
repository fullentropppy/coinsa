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
    let localCurrency: Currency
    let baseCurrency: Currency

    var date: Date
    var amountBase: Double
    var rateBaseToLocal: Double
    var category: ExpenseCategory
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
            ? "expense.navigationTitle.edit"
            : "expense.navigationTitle.create"
        )
    }
    
    var rateBaseToLocalText: String {
        String(format: String(localized: "expense.exchangeRate"), localCurrency.code)
    }
    
    var amountLocal: Double {
        guard rateBaseToLocal > 0 else { return 0 }
        return (amountBase / rateBaseToLocal).rounded()
    }
    
    // MARK: - Initialization

    convenience init(location: Location, baseCurrency: Currency) {
        self.init(location: location, expense: nil, baseCurrency: baseCurrency)
    }

    convenience init(expense: Expense, baseCurrency: Currency) {
        self.init(location: expense.location, expense: expense, baseCurrency: baseCurrency)
    }

    init(location: Location, expense: Expense?, baseCurrency: Currency) {
        self.location = expense?.location ?? location
        self.expense = expense
        self.localCurrency = Currency.from(self.location.currencyCodeLocal)
        self.baseCurrency = baseCurrency

        if let expense {
            date = expense.date
            amountBase = expense.amountBase
            rateBaseToLocal = expense.rateBaseToLocal
            category = expense.category
            comment = expense.comment ?? ""
        } else {
            date = .now
            amountBase = 0
            rateBaseToLocal = self.location.rateBaseToLocal
            category = .food
            comment = ""
        }
    }

    // MARK: - Public Methods

    func save(using repository: ExpenseRepository) {
        let normalizedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = normalizedComment.isEmpty ? nil : normalizedComment

        if let expense {
            repository.update(
                expense,
                date: date,
                amountInLocalCurrency: amountBase,
                rateToBaseCurrency: rateBaseToLocal,
                category: category,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                amountInLocalCurrency: amountBase,
                rateToBaseCurrency: rateBaseToLocal,
                category: category,
                location: location,
                comment: comment
            )
        }
    }
}
