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
    var baseAmount: Double
    var rateLocalToBase: Double
    var localAmount: Double
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
        baseAmount > 0 && rateLocalToBase > 0
    }
    
    var isHomeLocation: Bool {
        baseCurrency == localCurrency
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
        self.localCurrency = Currency.from(self.location.localCurrencyCode)
        self.baseCurrency = baseCurrency

        let resolvedDate: Date
        let resolvedAmountBase: Double
        let resolvedRateLocalToBase: Double
        let resolvedAmountLocal: Double
        let resolvedCategory: ExpenseCategory
        let resolvedComment: String

        if let expense {
            resolvedDate = expense.date
            resolvedAmountBase = expense.baseAmount
            resolvedRateLocalToBase = expense.rateLocalToBase
            resolvedAmountLocal = expense.localAmount
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
        baseAmount = resolvedAmountBase
        rateLocalToBase = resolvedRateLocalToBase
        localAmount = resolvedAmountLocal
        category = resolvedCategory
        comment = resolvedComment

        initialSnapshot = Snapshot(
            date: resolvedDate,
            baseAmount: resolvedAmountBase,
            rateLocalToBase: resolvedRateLocalToBase,
            category: resolvedCategory,
            comment: resolvedComment
        )
    }

    // MARK: - Public Methods
    
    func currency(for inputCurrency: InputCurrency) -> Currency {
        switch inputCurrency {
        case .base: baseCurrency
        case .local: localCurrency
        }
    }
    
    func amount(for inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base: baseAmount
        case .local: localAmount
        }
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base:
            baseAmount = newValue
            localAmount = rateLocalToBase > 0 ? (newValue / rateLocalToBase).rounded(to: 2) : 0
        case .local:
            localAmount = newValue
            baseAmount = newValue * rateLocalToBase
        }
    }
    
    func save(using repository: ExpenseRepository) {
        let normalizedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = normalizedComment.isEmpty ? nil : normalizedComment

        if let expense {
            repository.update(
                expense,
                date: date,
                localAmount: baseAmount,
                rateLocalToBase: rateLocalToBase,
                category: category,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                localAmount: baseAmount,
                rateLocalToBase: rateLocalToBase,
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
        let baseAmount: Double
        let rateLocalToBase: Double
        let category: ExpenseCategory
        let comment: String

        // MARK: - Initialization
        
        init(
            date: Date,
            baseAmount: Double,
            rateLocalToBase: Double,
            category: ExpenseCategory,
            comment: String
        ) {
            self.date = date
            self.baseAmount = baseAmount.rounded()
            self.rateLocalToBase = rateLocalToBase.rounded(to: 4)
            self.category = category
            self.comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        init(viewModel: ExpenseEditViewModel) {
            self.init(
                date: viewModel.date,
                baseAmount: viewModel.baseAmount,
                rateLocalToBase: viewModel.rateLocalToBase,
                category: viewModel.category,
                comment: viewModel.comment
            )
        }
    }
}
