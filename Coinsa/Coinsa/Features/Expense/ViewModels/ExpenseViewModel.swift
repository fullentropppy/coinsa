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

    private let initialSnapshot: Snapshot

    let expense: Expense?
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

    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        amountBase > 0 && rateBaseToLocal > 0
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
        let resolvedRateBaseToLocal: Double
        let resolvedCategory: ExpenseCategory
        let resolvedComment: String

        if let expense {
            resolvedDate = expense.date
            resolvedAmountBase = expense.amountBase
            resolvedRateBaseToLocal = expense.rateBaseToLocal
            resolvedCategory = expense.category
            resolvedComment = expense.comment ?? ""
        } else {
            resolvedDate = .now
            resolvedAmountBase = 0
            resolvedRateBaseToLocal = self.location.rateBaseToLocal
            resolvedCategory = .food
            resolvedComment = ""
        }

        date = resolvedDate
        amountBase = resolvedAmountBase
        rateBaseToLocal = resolvedRateBaseToLocal
        category = resolvedCategory
        comment = resolvedComment

        initialSnapshot = Snapshot(
            date: resolvedDate,
            amountBase: resolvedAmountBase,
            rateBaseToLocal: resolvedRateBaseToLocal,
            category: resolvedCategory,
            comment: resolvedComment
        )
    }

    // MARK: - Public Methods
    
    func currency(for inputCurrency: InputCurrency) -> Currency {
        switch inputCurrency {
        case .base:
            baseCurrency
        case .location:
            localCurrency
        }
    }
    
    func amount(for inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base:
            amountBase
        case .location:
            amountLocal
        }
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base:
            amountBase = newValue
        case .location:
            guard rateBaseToLocal > 0 else { return }
            amountBase = newValue * rateBaseToLocal
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

// MARK: - Snapshot

private extension ExpenseViewModel {
    struct Snapshot: Equatable {
        // MARK: - Stored Properties
        
        let date: Date
        let amountBase: Double
        let rateBaseToLocal: Double
        let category: ExpenseCategory
        let comment: String

        // MARK: - Initialization
        
        init(
            date: Date,
            amountBase: Double,
            rateBaseToLocal: Double,
            category: ExpenseCategory,
            comment: String
        ) {
            self.date = date
            self.amountBase = amountBase.rounded()
            self.rateBaseToLocal = rateBaseToLocal.rounded(to: 6)
            self.category = category
            self.comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        init(viewModel: ExpenseViewModel) {
            self.init(
                date: viewModel.date,
                amountBase: viewModel.amountBase,
                rateBaseToLocal: viewModel.rateBaseToLocal,
                category: viewModel.category,
                comment: viewModel.comment
            )
        }
    }
}

