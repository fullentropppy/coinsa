//
//  ExpenseEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ExpenseEditViewModel {
    // MARK: - Stored Properties

    private let initialSnapshot: Snapshot

    let expense: Expense?
    let location: Location
    let localCurrency: Currency
    let baseCurrency: Currency

    var date: Date
    var amountBase: Double
    var rateLocalToBase: Double
    var amountLocal: Double
    var category: ExpenseCategory
    var comment: String

    // MARK: - Computed Properties

    var isEditing: Bool {
        expense != nil
    }

    var navigationTitle: LocalizedStringResource {
        isEditing ? .expenseNavigationTitleEdit : .expenseNavigationTitleCreate
    }

    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        amountBase > 0 && rateLocalToBase > 0
    }
    
    // MARK: - Initialization

    convenience init(location: Location, baseCurrency: Currency) {
        self.init(expense: nil, location: location, baseCurrency: baseCurrency)
    }

    convenience init(expense: Expense, baseCurrency: Currency) {
        self.init(expense: expense, location: expense.location, baseCurrency: baseCurrency)
    }

    private init(expense: Expense?, location: Location, baseCurrency: Currency) {
        self.location = expense?.location ?? location
        self.expense = expense
        self.localCurrency = Currency.from(self.location.currencyCodeLocal)
        self.baseCurrency = baseCurrency

        let resolvedDate: Date
        let resolvedAmountBase: Double
        let resolvedRateLocalToBase: Double
        let resolvedAmountLocal: Double
        let resolvedCategory: ExpenseCategory
        let resolvedComment: String

        if let expense {
            resolvedDate = expense.date
            resolvedAmountBase = expense.amountBase
            resolvedRateLocalToBase = expense.rateLocalToBase
            resolvedAmountLocal = expense.amountLocal
            resolvedCategory = expense.category
            resolvedComment = expense.comment ?? ""
        } else {
            resolvedDate = .now
            resolvedAmountBase = 0
            resolvedRateLocalToBase = self.location.rateLocalToBase
            resolvedAmountLocal = 0
            resolvedCategory = .food
            resolvedComment = ""
        }

        date = resolvedDate
        amountBase = resolvedAmountBase
        rateLocalToBase = resolvedRateLocalToBase
        amountLocal = resolvedAmountLocal
        category = resolvedCategory
        comment = resolvedComment

        initialSnapshot = Snapshot(
            date: resolvedDate,
            amountBase: resolvedAmountBase,
            rateLocalToBase: resolvedRateLocalToBase,
            category: resolvedCategory,
            comment: resolvedComment
        )
    }

    // MARK: - Public Methods
    
    func currency(for inputCurrency: InputCurrency) -> Currency {
        switch inputCurrency {
        case .base: baseCurrency
        case .location: localCurrency
        }
    }
    
    func amount(for inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base: amountBase
        case .location: amountLocal
        }
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base:
            amountBase = newValue
            amountLocal = rateLocalToBase > 0 ? (newValue / rateLocalToBase).rounded(to: 2) : 0
        case .location:
            amountLocal = newValue
            amountBase = newValue * rateLocalToBase
        }
    }
    
    func save(using repository: ExpenseRepository) {
        let normalizedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = normalizedComment.isEmpty ? nil : normalizedComment

        if let expense {
            repository.update(
                expense,
                date: date,
                amountInLocalCurrency: amountBase,
                rateToBaseCurrency: rateLocalToBase,
                category: category,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                amountInLocalCurrency: amountBase,
                rateToBaseCurrency: rateLocalToBase,
                category: category,
                location: location,
                comment: comment
            )
        }
    }
}

// MARK: - Snapshot

private extension ExpenseEditViewModel {
    struct Snapshot: Equatable {
        // MARK: - Stored Properties
        
        let date: Date
        let amountBase: Double
        let rateLocalToBase: Double
        let category: ExpenseCategory
        let comment: String

        // MARK: - Initialization
        
        init(
            date: Date,
            amountBase: Double,
            rateLocalToBase: Double,
            category: ExpenseCategory,
            comment: String
        ) {
            self.date = date
            self.amountBase = amountBase.rounded()
            self.rateLocalToBase = rateLocalToBase.rounded(to: 4)
            self.category = category
            self.comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        init(viewModel: ExpenseEditViewModel) {
            self.init(
                date: viewModel.date,
                amountBase: viewModel.amountBase,
                rateLocalToBase: viewModel.rateLocalToBase,
                category: viewModel.category,
                comment: viewModel.comment
            )
        }
    }
}
