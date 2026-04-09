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
    
    private let currencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRate = false
    
    let expense: Expense?
    let location: Location
    let localCurrency: Currency
    let baseCurrency: Currency

    var date: Date
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
    
    var isRateLoading: Bool {
        currencyConverter.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { currencyConverter.rateLoadingError }
        set { currencyConverter.rateLoadingError = newValue }
    }
    
    var baseAmount: Double {
        get { amountManager.baseAmount }
        set { amountManager.updateBaseAmount(newValue) }
    }
    
    var localAmount: Double {
        get { amountManager.localAmount }
        set { amountManager.updateLocalAmount(newValue) }
    }
    
    var rateLocalToBase: Double {
        get { currencyConverter.rateLocalToBase }
        set {
            currencyConverter.updateRate(newValue)
            amountManager.updateFromRateChange(currentInput: .base)
        }
    }
    
    // MARK: - Initialization

    convenience init(location: Location, baseCurrency: Currency, preselectedCategory: ExpenseCategory? = nil) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            expense: nil,
            location: location,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider,
            preselectedCategory: preselectedCategory
        )
    }

    convenience init(expense: Expense, baseCurrency: Currency) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            expense: expense,
            location: expense.location,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider
        )
    }

    private init(
        expense: Expense?,
        location: Location,
        baseCurrency: Currency,
        exchangeRateProvider: ExchangeRateProvider,
        preselectedCategory: ExpenseCategory? = nil,
    ) {
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
            resolvedCategory = preselectedCategory ?? .food
            resolvedComment = ""
        }

        self.date = resolvedDate
        self.category = resolvedCategory
        self.comment = resolvedComment

        self.currencyConverter = CurrencyConverter(
            baseCurrency: baseCurrency,
            localCurrency: self.localCurrency,
            initialRate: resolvedRateLocalToBase,
            exchangeRateProvider: exchangeRateProvider
        )
        
        self.amountManager = AmountManager(
            converter: currencyConverter,
            baseAmount: resolvedAmountBase,
            localAmount: resolvedAmountLocal
        )
        
        initialSnapshot = Snapshot(
            date: resolvedDate,
            baseAmount: resolvedAmountBase,
            rateLocalToBase: resolvedRateLocalToBase,
            category: resolvedCategory,
            comment: resolvedComment
        )
    }

    // MARK: - Public Methods
    
    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate && !isEditing && !isHomeLocation else { return }
            
        hasLoadedInitialRate = true
    
        currencyConverter.requestRateRefresh { [weak self] rate in
            guard let self else { return }
            
            rateLocalToBase = rate
            initialSnapshot = Snapshot(
                date: initialSnapshot.date,
                baseAmount: initialSnapshot.baseAmount,
                rateLocalToBase: rateLocalToBase,
                category: initialSnapshot.category,
                comment: initialSnapshot.comment
            )
        }
    }

    func requestRateRefresh() {
        currencyConverter.requestRateRefresh { [weak self] _ in
            self?.amountManager.updateFromRateChange(currentInput: .base)
        }
    }
    
    func currency(for inputCurrency: InputCurrency) -> Currency {
        switch inputCurrency {
        case .base: baseCurrency
        case .local: localCurrency
        }
    }
    
    func amount(for inputCurrency: InputCurrency) -> Double {
        amountManager.amount(for: inputCurrency)
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        amountManager.updateAmount(newValue, for: inputCurrency)
    }
    
    func save(using repository: ExpenseRepository) {
        let normalizedComment = comment.trimmed
        let comment = normalizedComment.isEmpty ? nil : normalizedComment

        if let expense {
            repository.update(
                expense,
                date: date,
                baseAmount: baseAmount,
                rateLocalToBase: rateLocalToBase,
                category: category,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                baseAmount: baseAmount,
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
            self.baseAmount = baseAmount
            self.rateLocalToBase = rateLocalToBase
            self.category = category
            self.comment = comment
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
