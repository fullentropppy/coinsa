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
    private var calculationContext: ExpenseCalculationContext {
        ExpenseCalculationContext(
            baseAmount: baseAmount,
            baseCurrency: baseCurrency,
            expenseCurrency: expenseCurrency,
            rateExpenseToBase: rateExpenseToBase,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment
        )
    }
    
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
    
    var showsRateExpenseToBase: Bool {
        !isExpenseBaseCurrency
    }
    
    var showsRateExpenseToLocation: Bool {
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
        && (!showsRateExpenseToBase || rateExpenseToBase > 0)
        && (!showsRateExpenseToLocation || rateExpenseToLocation > 0)
    }
    
    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var locationCurrency: Currency {
        location.locationCurrency
    }
    
    var expenseCurrency: Currency {
        baseCurrencyConverter.quoteCurrency
    }
    
    // MARK: - Состояние UI. Общие данные
    
    var date: Date {
        didSet { timeZone = .current }
    }
    
    var timeZone: TimeZone
    var category: ExpenseCategory
    var subcategory: ExpenseSubcategory
    var comment: String
    
    // MARK: - Состояние UI. Сумма
    
    var baseAmount: Double {
        get { amountManager.baseAmount }
        set { amountManager.updateBaseAmount(newValue, useExchangeAdjustment: useExchangeAdjustment) }
    }
    
    var expenseAmount: Double {
        get { amountManager.quoteAmount }
        set { amountManager.updateQuoteAmount(newValue, useExchangeAdjustment: useExchangeAdjustment) }
    }
    
    // MARK: - Состояние UI. Курс обмена
    
    var rateExpenseToBase: Double {
        get { baseCurrencyConverter.rateQuoteToBase }
        set { baseCurrencyConverter.updateRate(newValue) }
    }
    
    var rateExpenseToLocation: Double {
        get { locationCurrencyConverter.rateQuoteToBase }
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
        guard useExchangeAdjustment && exchangeAdjustment > 0 else {
            return nil
        }
        
        if expenseCurrency == locationCurrency {
            return .expenseAdjustedExchangeRateShort(
                expenseCurrencyCode: expenseCurrency.code,
                effectiveRateExpenseToBase: calculationContext.rateExpenseToBase.numberFormat(fractionLength: 4),
                baseCurrencyCode: baseCurrency.code
            )
        } else {
            return .expenseAdjustedExchangeRateShortDouble(
                expenseCurrencyCode: expenseCurrency.code,
                effectiveRateExpenseToBase: calculationContext.rateExpenseToBase.numberFormat(fractionLength: 4),
                baseCurrencyCode: baseCurrency.code,
                effectiveRateExpenseToLocation: calculationContext.rateExpenseToLocation.numberFormat(fractionLength: 4),
                locationCurrencyCode: locationCurrency.code
            )
        }
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
        let date = CivilDateTime.now.storedDate
        let category = preselectedCategory ?? .defaultValue
        
        self.init(
            location: location,
            expense: nil,
            date: date,
            timeZone: .current,
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
            date: expense.civilDateTime.storedDate,
            timeZone: expense.timeZone,
            baseAmount: expense.baseAmount,
            expenseAmount: expense.amount(in: .expense),
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
        timeZone: TimeZone,
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
        self.timeZone = timeZone
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
            quoteCurrency: expenseCurrency,
            rateQuoteToBase: normalizedRateExpenseToBase,
            exchangeAdjustment: exchangeAdjustment
        )
        
        self.locationCurrencyConverter = CurrencyConverter(
            exchangeRateProvider: locationExchangeRateProvider,
            baseCurrency: location.locationCurrency,
            quoteCurrency: expenseCurrency,
            rateQuoteToBase: normalizedRateExpenseToLocation,
            exchangeAdjustment: 0
        )
        
        self.amountManager = AmountManager(
            converter: baseCurrencyConverter,
            baseAmount: baseAmount,
            quoteAmount: expenseAmount
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
    
    func updateExpenseCurrency(_ newCurrency: Currency, currencySide: CurrencySide) {
        guard newCurrency != expenseCurrency else { return }
        
        baseCurrencyConverter.updateQuoteCurrency(newCurrency) { [weak self] in
            guard let self else { return }
            
            amountManager.updateFromRateChange(
                for: currencySide,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
        
        locationCurrencyConverter.updateQuoteCurrency(newCurrency)
    }
    
    func currency(for currencySide: CurrencySide) -> Currency {
        switch currencySide {
        case .base: baseCurrency
        case .quote: expenseCurrency
        }
    }
    
    // MARK: - Операции с суммой
    
    func amount(for currencySide: CurrencySide) -> Double {
        amountManager.amount(for: currencySide)
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: CurrencySide) {
        amountManager.updateAmount(
            newValue,
            for: inputCurrency,
            useExchangeAdjustment: useExchangeAdjustment
        )
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRateExpenseToBase(_ newRate: Double, currencySide: CurrencySide) {
        baseCurrencyConverter.updateRate(newRate)
        amountManager.updateFromRateChange(
            for: currencySide,
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
    
    func requestRateExpenseToBaseRefresh(for inputCurrency: CurrencySide = .base) {
        baseCurrencyConverter.requestRateRefresh { [weak self] _ in
            guard let self else { return }
            amountManager.updateFromRateChange(
                for: inputCurrency,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
    }
    
    func requestRateExpenseToLocationRefresh() {
        locationCurrencyConverter.requestRateRefresh()
    }
    
    private func requestInitialRateExpenseToBaseIfNeeded() {
        guard showsRateExpenseToBase else { return }
        
        baseCurrencyConverter.requestRateRefresh { [weak self] _ in
            self?.syncInitialSnapshotWithCurrentRates()
        }
    }
    
    private func requestInitialRateExpenseToLocationIfNeeded() {
        guard showsRateExpenseToLocation else { return }
        
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
    
    func updatePaymentMethod(_ method: PaymentMethod, currencySide: CurrencySide) {
        paymentMethod = method
        syncExchangeAdjustmentAndRecalculate(currencySide: currencySide)
    }
    
    func updateExchangeAdjustment(_ newAdjustment: Double, currencySide: CurrencySide) {
        exchangeAdjustment = newAdjustment
        syncExchangeAdjustmentAndRecalculate(currencySide: currencySide)
    }
    
    private func syncExchangeAdjustmentAndRecalculate(currencySide: CurrencySide) {
        baseCurrencyConverter.updateExchangeAdjustment(exchangeAdjustment)
        amountManager.updateFromRateChange(for: currencySide, useExchangeAdjustment: useExchangeAdjustment)
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
                latitude: nil,
                longitude: nil,
                horizontalAccuracy: nil,
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
                latitude: nil,
                longitude: nil,
                horizontalAccuracy: nil,
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
