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
    // MARK: - Зависимости
    
    private let currencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    
    let expense: Expense?
    let location: Location
    let localCurrency: Currency
    let baseCurrency: Currency
    
    // MARK: - Внутреннее состояние
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRate = false
        
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var isEdit: Bool {
        expense != nil
    }

    var isHomeLocation: Bool {
        baseCurrency == localCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        isEdit ? .expenseNavigationTitleEdit : .expenseNavigationTitleCreate
    }

    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        baseAmount > 0 && rateLocalToBase > 0
    }
        
    // MARK: - Состояние UI. Общие данные
    
    var date: Date
    var category: ExpenseCategory
    var comment: String
    
    // MARK: - Состояние UI. Сумма
    
    var baseAmount: Double {
        get { amountManager.baseAmount }
        set { amountManager.updateBaseAmount(newValue) }
    }
    
    var localAmount: Double {
        get { amountManager.localAmount }
        set { amountManager.updateLocalAmount(newValue) }
    }
    
    // MARK: - Состояние UI. Курс обмена
    
    var rateLocalToBase: Double {
        get { currencyConverter.rateLocalToBase }
        set { currencyConverter.updateRate(newValue) }
    }
    
    var isRateLoading: Bool {
        currencyConverter.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { currencyConverter.rateLoadingError }
        set { currencyConverter.rateLoadingError = newValue }
    }

    var adjustedRateDescription: LocalizedStringResource? {
        guard showsExchangeAdjustmentInput && exchangeAdjustment > 0 else {
            return nil
        }

        return .expenseAdjustedExchangeRateShort(
            localCurrencyCode: localCurrency.code,
            effectiveRateLocalToBase: currencyConverter.effectiveRateLocalToBase.formatted(
                .number.precision(.fractionLength(4))
            ),
            baseCurrencyCode: baseCurrency.code
        )
    }
    
    // MARK: - Состояние UI. Оплата
    
    var paymentMethod: PaymentMethod
    var exchangeAdjustment: Double
    
    var showsExchangeAdjustmentInput: Bool {
        !isHomeLocation && paymentMethod != .cash
    }

    // MARK: - Инициализация
    
    convenience init(
        expense: Expense,
        baseCurrency: Currency
    ) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            expense: expense,
            location: expense.location,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider
        )
    }
    
    convenience init(
        location: Location,
        baseCurrency: Currency,
        preselectedCategory: ExpenseCategory? = nil,
        preselectedPaymentMethod: PaymentMethod? = nil
    ) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            expense: nil,
            location: location,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider,
            preselectedCategory: preselectedCategory,
            preselectedPaymentMethod: preselectedPaymentMethod
        )
    }

    private init(
        expense: Expense?,
        location: Location,
        baseCurrency: Currency,
        exchangeRateProvider: ExchangeRateProvider,
        preselectedCategory: ExpenseCategory? = nil,
        preselectedPaymentMethod: PaymentMethod? = nil
    ) {
        self.location = expense?.location ?? location
        self.expense = expense
        self.localCurrency = Currency.from(self.location.localCurrencyCode)
        self.baseCurrency = baseCurrency

        let resolvedDate: Date
        let resolvedAmountBase: Double
        let resolvedRateLocalToBase: Double
        let resolvedAmountLocal: Double
        let resolvedPaymentMethod: PaymentMethod
        let resolvedExchangeAdjustment: Double
        let resolvedCategory: ExpenseCategory
        let resolvedComment: String

        if let expense {
            resolvedDate = expense.date
            resolvedAmountBase = expense.baseAmount
            resolvedRateLocalToBase = expense.rateLocalToBase
            resolvedAmountLocal = expense.localAmount
            resolvedPaymentMethod = expense.paymentMethod
            resolvedExchangeAdjustment = expense.exchangeAdjustment
            resolvedCategory = expense.category
            resolvedComment = expense.comment ?? ""
        } else {
            resolvedDate = .now
            resolvedAmountBase = 0
            resolvedRateLocalToBase = self.location.rateLocalToBase
            resolvedAmountLocal = 0
            resolvedPaymentMethod = preselectedPaymentMethod ?? .cash
            resolvedExchangeAdjustment = location.exchangeAdjustment
            resolvedCategory = preselectedCategory ?? .food
            resolvedComment = ""
        }

        self.date = resolvedDate
        self.paymentMethod = resolvedPaymentMethod
        self.exchangeAdjustment = resolvedExchangeAdjustment
        self.category = resolvedCategory
        self.comment = resolvedComment

        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: baseCurrency,
            localCurrency: self.localCurrency,
            rateLocalToBase: resolvedRateLocalToBase,
            exchangeAdjustment: resolvedExchangeAdjustment
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
            paymentMethod: resolvedPaymentMethod,
            exchangeAdjustment: resolvedExchangeAdjustment,
            category: resolvedCategory,
            comment: resolvedComment
        )
    }

    // MARK: - Операции с валютой
    
    func currency(for inputCurrency: InputCurrency) -> Currency {
        switch inputCurrency {
        case .base: baseCurrency
        case .local: localCurrency
        }
    }
    
    // MARK: - Операции с суммой
    
    func amount(for inputCurrency: InputCurrency) -> Double {
        amountManager.amount(for: inputCurrency)
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        amountManager.updateAmount(newValue, for: inputCurrency)
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRate(_ newRate: Double, currentInput: InputCurrency) {
        currencyConverter.updateRate(newRate)
        amountManager.updateFromRateChange(inputCurrency: currentInput)
    }
    
    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate && !isEdit && !isHomeLocation else { return }
            
        hasLoadedInitialRate = true
    
        currencyConverter.requestRateRefresh { [weak self] rate in
            guard let self else { return }
            
            rateLocalToBase = rate
            initialSnapshot = Snapshot(
                date: initialSnapshot.date,
                baseAmount: initialSnapshot.baseAmount,
                rateLocalToBase: rateLocalToBase,
                paymentMethod: initialSnapshot.paymentMethod,
                exchangeAdjustment: initialSnapshot.exchangeAdjustment,
                category: initialSnapshot.category,
                comment: initialSnapshot.comment
            )
        }
    }
    
    func requestRateRefresh(for inputCurrency: InputCurrency = .base) {
        currencyConverter.requestRateRefresh { [weak self] _ in
            self?.amountManager.updateFromRateChange(inputCurrency: inputCurrency)
        }
    }
    
    // MARK: - Операции с оплатой

    func updatePaymentMethod(_ method: PaymentMethod, currentInput: InputCurrency) {
        paymentMethod = method
        syncExchangeAdjustmentAndRecalculate(currentInput: currentInput)
    }
    
    func updateExchangeAdjustment(_ newPercentage: Double, currentInput: InputCurrency) {
        exchangeAdjustment = max(0, newPercentage)
        syncExchangeAdjustmentAndRecalculate(currentInput: currentInput)
    }
    
    private func syncExchangeAdjustmentAndRecalculate(currentInput: InputCurrency) {
        currencyConverter.updateExchangeAdjustment(exchangeAdjustment)
        amountManager.updateFromRateChange(inputCurrency: currentInput)
    }
    
    // MARK: - Операции с хранилищем
    
    func save(using repository: ExpenseRepository) {
        let normalizedComment = comment.trimmed
        let comment = normalizedComment.isEmpty ? nil : normalizedComment

        if let expense {
            repository.update(
                expense,
                date: date,
                baseAmount: baseAmount,
                rateLocalToBase: rateLocalToBase,
                paymentMethod: paymentMethod,
                exchangeAdjustment: exchangeAdjustment,
                category: category,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                baseAmount: baseAmount,
                rateLocalToBase: rateLocalToBase,
                paymentMethod: paymentMethod,
                exchangeAdjustment: exchangeAdjustment,
                category: category,
                location: location,
                comment: comment
            )
        }
    }
}

// MARK: - Внутренние типы

private extension ExpenseEditViewModel {
    struct Snapshot: Equatable {
        // MARK: - Свойства
        
        let date: Date
        let baseAmount: Double
        let rateLocalToBase: Double
        let paymentMethod: PaymentMethod
        let exchangeAdjustment: Double
        let category: ExpenseCategory
        let comment: String

        // MARK: - Инициализация
        
        init(viewModel: ExpenseEditViewModel) {
            self.init(
                date: viewModel.date,
                baseAmount: viewModel.baseAmount,
                rateLocalToBase: viewModel.rateLocalToBase,
                paymentMethod: viewModel.paymentMethod,
                exchangeAdjustment: viewModel.exchangeAdjustment,
                category: viewModel.category,
                comment: viewModel.comment
            )
        }
        
        init(
            date: Date,
            baseAmount: Double,
            rateLocalToBase: Double,
            paymentMethod: PaymentMethod,
            exchangeAdjustment: Double,
            category: ExpenseCategory,
            comment: String
        ) {
            self.date = date
            self.baseAmount = baseAmount
            self.rateLocalToBase = rateLocalToBase
            self.paymentMethod = paymentMethod
            self.exchangeAdjustment = exchangeAdjustment
            self.category = category
            self.comment = comment
        }
    }
}
