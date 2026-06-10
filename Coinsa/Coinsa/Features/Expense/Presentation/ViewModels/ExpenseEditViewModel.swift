//
//  ExpenseEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import Foundation
import Observation

/// ViewModel для экрана создания/редактирования траты.
@MainActor
@Observable
final class ExpenseEditViewModel {
    // MARK: - Зависимости
    
    private let baseCurrencyConverter: CurrencyConverter
    private let locationCurrencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    
    let expense: Expense?
    let location: Location
    
    // MARK: - Внутреннее состояние
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRates = false
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var isEdit: Bool {
        expense != nil
    }
    
    var isExpenseBaseCurrency: Bool {
        expenseCurrency == baseCurrency
    }
    
    var isExpenseLocationCurrency: Bool {
        expenseCurrency == locationCurrency
    }
    
    var shouldShowRateExpenseToBase: Bool {
        !isExpenseBaseCurrency
    }
    
    var shouldShowRateExpenseToLocation: Bool {
        !isExpenseLocationCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        isEdit ? .expenseNavigationTitleEdit : .expenseNavigationTitleCreate
    }
    
    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        baseAmount > 0
        && (!shouldShowRateExpenseToBase || rateExpenseToBase > 0)
        && (!shouldShowRateExpenseToLocation || rateExpenseToLocation > 0)
    }
    
    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var locationCurrency: Currency {
        location.locationCurrency
    }
    
    var expenseCurrency: Currency {
        baseCurrencyConverter.locationCurrency
    }
    
    // MARK: - Состояние UI. Общие данные
    
    var date: Date
    var category: ExpenseCategory
    var subcategory: ExpenseSubcategory
    var comment: String
    
    // MARK: - Состояние UI. Сумма
    
    var baseAmount: Double {
        get { amountManager.baseAmount }
        set { amountManager.updateBaseAmount(newValue, useExchangeAdjustment: useExchangeAdjustment) }
    }
    
    var expenseAmount: Double {
        get { amountManager.localAmount }
        set { amountManager.updateLocalAmount(newValue, useExchangeAdjustment: useExchangeAdjustment) }
    }
    
    // MARK: - Состояние UI. Курс обмена
    
    var rateExpenseToBase: Double {
        get { baseCurrencyConverter.rateLocationToBase }
        set { baseCurrencyConverter.updateRate(newValue) }
    }
    
    var rateExpenseToLocation: Double {
        get { locationCurrencyConverter.rateLocationToBase }
        set { locationCurrencyConverter.updateRate(newValue) }
    }
    
    var isRateExpenseToBaseLoading: Bool {
        baseCurrencyConverter.isRateLoading
    }
    
    var isRateExpenseToLocationLoading: Bool {
        locationCurrencyConverter.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { baseCurrencyConverter.rateLoadingError ?? locationCurrencyConverter.rateLoadingError }
        set {
            baseCurrencyConverter.rateLoadingError = newValue
            locationCurrencyConverter.rateLoadingError = newValue
        }
    }
    
    var adjustedRateDescription: LocalizedStringResource? {
        guard useExchangeAdjustment && exchangeAdjustment > 0 else { return nil }
        
        return .expenseAdjustedExchangeRateShort(
            localCurrencyCode: expenseCurrency.code,
            effectiveRateLocalToBase: baseCurrencyConverter.effectiveRateLocationToBase.numberFormat(fractionLength: 4),
            baseCurrencyCode: baseCurrency.code
        )
    }
    
    // MARK: - Состояние UI. Оплата
    
    var paymentMethod: PaymentMethod
    var exchangeAdjustment: Double
    
    var useExchangeAdjustment: Bool {
        !isExpenseBaseCurrency && paymentMethod == .card
    }
    
    // MARK: - Инициализация
    
    /// Создает ViewModel для новой траты.
    /// - Parameters:
    ///   - location: Локация траты.
    ///   - preselectedCategory: Предустановленная категория.
    ///   - preselectedPaymentMethod: Предустановленный способ оплаты.
    convenience init(
        forCreateWith location: Location,
        preselectedCategory: ExpenseCategory? = nil,
        preselectedPaymentMethod: PaymentMethod? = nil
    ) {
        let now = Date()
        let date = min(max(now, location.startDate.startOfDay), location.endDate.endOfDay)
        let category = preselectedCategory ?? .defaultValue
        
        self.init(
            location: location,
            expense: nil,
            date: date,
            baseAmount: 0,
            expenseAmount: 0,
            expenseCurrency: location.locationCurrency,
            rateExpenseToBase: location.rateLocationToBase,
            rateExpenseToLocation: 1,
            paymentMethod: preselectedPaymentMethod ?? .card,
            exchangeAdjustment: location.exchangeAdjustment,
            category: preselectedCategory ?? .defaultValue,
            subcategory: .defaultValue(with: category),
            comment: ""
        )
    }
    
    /// Создает ViewModel для редактирования существующей траты.
    /// - Parameter expense: Редактируемая трата.
    convenience init(forEdit expense: Expense) {
        self.init(
            location: expense.location!,
            expense: expense,
            date: expense.date,
            baseAmount: expense.baseAmount,
            expenseAmount: expense.expenseAmount,
            expenseCurrency: expense.expenseCurrency,
            rateExpenseToBase: expense.rateExpenseToBase,
            rateExpenseToLocation: expense.rateExpenseToLocation,
            paymentMethod: expense.paymentMethod,
            exchangeAdjustment: expense.exchangeAdjustment,
            category: expense.category,
            subcategory: expense.subcategory,
            comment: expense.comment ?? ""
        )
    }
    
    private init(
        location: Location,
        expense: Expense?,
        date: Date,
        baseAmount: Double,
        expenseAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToBase: Double,
        rateExpenseToLocation: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        comment: String
    ) {
        self.location = location
        self.expense = expense
        self.date = date
        self.paymentMethod = paymentMethod
        self.exchangeAdjustment = exchangeAdjustment
        self.category = category
        self.subcategory = subcategory
        self.comment = comment
        
        let baseExchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        let locationExchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        let normalizedRateExpenseToBase = expenseCurrency == location.baseCurrency ? 1 : rateExpenseToBase
        let normalizedRateExpenseToLocation = expenseCurrency == location.locationCurrency ? 1 : rateExpenseToLocation
        
        self.baseCurrencyConverter = CurrencyConverter(
            exchangeRateProvider: baseExchangeRateProvider,
            baseCurrency: location.baseCurrency,
            locationCurrency: expenseCurrency,
            rateLocationToBase: normalizedRateExpenseToBase,
            exchangeAdjustment: exchangeAdjustment
        )
        
        self.locationCurrencyConverter = CurrencyConverter(
            exchangeRateProvider: locationExchangeRateProvider,
            baseCurrency: location.locationCurrency,
            locationCurrency: expenseCurrency,
            rateLocationToBase: normalizedRateExpenseToLocation,
            exchangeAdjustment: 0
        )
        
        self.amountManager = AmountManager(
            converter: baseCurrencyConverter,
            baseAmount: baseAmount,
            localAmount: expenseAmount
        )
        
        initialSnapshot = Snapshot(
            date: date,
            baseAmount: baseAmount,
            expenseCurrency: expenseCurrency,
            rateExpenseToBase: normalizedRateExpenseToBase,
            rateExpenseToLocation: normalizedRateExpenseToLocation,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment,
            category: category,
            subcategory: subcategory,
            comment: comment
        )
    }
    
    // MARK: - Операции с валютой
    
    func updateExpenseCurrency(_ newCurrency: Currency, currentInput: InputCurrency) {
        guard newCurrency != expenseCurrency else { return }
        
        baseCurrencyConverter.updateLocalCurrency(newCurrency) { [weak self] in
            guard let self else { return }
            
            amountManager.updateFromRateChange(
                inputCurrency: currentInput,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
        
        locationCurrencyConverter.updateLocalCurrency(newCurrency)
    }
    
    func currency(for inputCurrency: InputCurrency) -> Currency {
        switch inputCurrency {
        case .base: baseCurrency
        case .local: expenseCurrency
        }
    }
    
    // MARK: - Операции с суммой
    
    func amount(for inputCurrency: InputCurrency) -> Double {
        amountManager.amount(for: inputCurrency)
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: InputCurrency) {
        amountManager.updateAmount(
            newValue,
            for: inputCurrency,
            useExchangeAdjustment: useExchangeAdjustment
        )
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRateExpenseToBase(_ newRate: Double, currentInput: InputCurrency) {
        baseCurrencyConverter.updateRate(newRate)
        amountManager.updateFromRateChange(
            inputCurrency: currentInput,
            useExchangeAdjustment: useExchangeAdjustment
        )
    }
    
    func updateRateExpenseToLocation(_ newRate: Double) {
        locationCurrencyConverter.updateRate(newRate)
    }
    
    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRates && !isEdit else { return }
        
        hasLoadedInitialRates = true
        requestInitialRateExpenseToBaseIfNeeded()
        requestInitialRateExpenseToLocationIfNeeded()
    }
    
    func requestRateExpenseToBaseRefresh(for inputCurrency: InputCurrency = .base) {
        baseCurrencyConverter.requestRateRefresh { [weak self] _ in
            guard let self else { return }
            amountManager.updateFromRateChange(
                inputCurrency: inputCurrency,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
    }
    
    func requestRateExpenseToLocationRefresh() {
        locationCurrencyConverter.requestRateRefresh()
    }
    
    private func requestInitialRateExpenseToBaseIfNeeded() {
        guard shouldShowRateExpenseToBase else { return }
        
        baseCurrencyConverter.requestRateRefresh { [weak self] _ in
            self?.syncInitialSnapshotWithCurrentRates()
        }
    }
    
    private func requestInitialRateExpenseToLocationIfNeeded() {
        guard shouldShowRateExpenseToLocation else { return }
        
        locationCurrencyConverter.requestRateRefresh { [weak self] _ in
            self?.syncInitialSnapshotWithCurrentRates()
        }
    }
    
    private func syncInitialSnapshotWithCurrentRates() {
        initialSnapshot = Snapshot(
            date: initialSnapshot.date,
            baseAmount: initialSnapshot.baseAmount,
            expenseCurrency: initialSnapshot.expenseCurrency,
            rateExpenseToBase: rateExpenseToBase,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethod: initialSnapshot.paymentMethod,
            exchangeAdjustment: initialSnapshot.exchangeAdjustment,
            category: initialSnapshot.category,
            subcategory: initialSnapshot.subcategory,
            comment: initialSnapshot.comment
        )
    }
    
    // MARK: - Операции с категорией
    
    func updateCategory(_ newCategory: ExpenseCategory) {
        category = newCategory
        subcategory = .defaultValue(with: category)
    }
    
    // MARK: - Операции с оплатой
    
    func updatePaymentMethod(_ method: PaymentMethod, currentInput: InputCurrency) {
        paymentMethod = method
        syncExchangeAdjustmentAndRecalculate(currentInput: currentInput)
    }
    
    func updateExchangeAdjustment(_ newAdjustment: Double, currentInput: InputCurrency) {
        exchangeAdjustment = newAdjustment
        syncExchangeAdjustmentAndRecalculate(currentInput: currentInput)
    }
    
    private func syncExchangeAdjustmentAndRecalculate(currentInput: InputCurrency) {
        baseCurrencyConverter.updateExchangeAdjustment(exchangeAdjustment)
        amountManager.updateFromRateChange(inputCurrency: currentInput, useExchangeAdjustment: useExchangeAdjustment)
    }
    
    // MARK: - Операции с хранилищем
    
    private var storedRateExpenseToBase: Double {
        isExpenseBaseCurrency ? 1 : rateExpenseToBase
    }
    
    private var storedRateExpenseToLocation: Double {
        isExpenseLocationCurrency ? 1 : rateExpenseToLocation
    }
    
    func save(using repository: ExpenseRepository) {
        if let expense {
            repository.update(
                expense,
                date: date,
                baseAmount: baseAmount,
                expenseCurrency: expenseCurrency,
                rateExpenseToBase: storedRateExpenseToBase,
                rateExpenseToLocation: storedRateExpenseToLocation,
                paymentMethod: paymentMethod,
                exchangeAdjustment: exchangeAdjustment,
                category: category,
                subcategory: subcategory,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                baseAmount: baseAmount,
                expenseCurrency: expenseCurrency,
                rateExpenseToBase: storedRateExpenseToBase,
                rateExpenseToLocation: storedRateExpenseToLocation,
                paymentMethod: paymentMethod,
                exchangeAdjustment: exchangeAdjustment,
                category: category,
                subcategory: subcategory,
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
        let expenseCurrency: Currency
        let rateExpenseToBase: Double
        let rateExpenseToLocation: Double
        let paymentMethod: PaymentMethod
        let exchangeAdjustment: Double
        let category: ExpenseCategory
        let subcategory: ExpenseSubcategory
        let comment: String?
        
        // MARK: - Инициализация
        
        init(viewModel: ExpenseEditViewModel) {
            self.init(
                date: viewModel.date,
                baseAmount: viewModel.baseAmount,
                expenseCurrency: viewModel.expenseCurrency,
                rateExpenseToBase: viewModel.storedRateExpenseToBase,
                rateExpenseToLocation: viewModel.storedRateExpenseToLocation,
                paymentMethod: viewModel.paymentMethod,
                exchangeAdjustment: viewModel.exchangeAdjustment,
                category: viewModel.category,
                subcategory: viewModel.subcategory,
                comment: viewModel.comment
            )
        }
        
        init(
            date: Date,
            baseAmount: Double,
            expenseCurrency: Currency,
            rateExpenseToBase: Double,
            rateExpenseToLocation: Double,
            paymentMethod: PaymentMethod,
            exchangeAdjustment: Double,
            category: ExpenseCategory,
            subcategory: ExpenseSubcategory,
            comment: String?
        ) {
            self.date = date
            self.baseAmount = baseAmount
            self.expenseCurrency = expenseCurrency
            self.rateExpenseToBase = rateExpenseToBase
            self.rateExpenseToLocation = rateExpenseToLocation
            self.paymentMethod = paymentMethod
            self.exchangeAdjustment = exchangeAdjustment
            self.category = category
            self.subcategory = subcategory
            self.comment = comment
        }
    }
}
