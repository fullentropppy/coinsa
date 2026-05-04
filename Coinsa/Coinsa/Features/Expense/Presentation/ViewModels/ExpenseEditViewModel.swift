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
    
    private let currencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    
    let expense: Expense?
    let location: Location
    
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
    
    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var localCurrency: Currency {
        location.localCurrency
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
        guard useExchangeAdjustment && exchangeAdjustment > 0 else { return nil }
        
        return .expenseAdjustedExchangeRateShort(
            localCurrencyCode: localCurrency.code,
            effectiveRateLocalToBase: currencyConverter.effectiveRateLocalToBase.numberFormat(fractionLength: 4),
            baseCurrencyCode: baseCurrency.code
        )
    }
    
    // MARK: - Состояние UI. Оплата
    
    var paymentMethod: PaymentMethod
    var exchangeAdjustment: Double
    
    var useExchangeAdjustment: Bool {
        !isHomeLocation && paymentMethod == .card
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
        
        self.init(
            location: location,
            expense: nil,
            date: date,
            baseAmount: 0,
            localAmount: 0,
            rateLocalToBase: location.rateLocalToBase,
            paymentMethod: preselectedPaymentMethod ?? .card,
            exchangeAdjustment: location.exchangeAdjustment,
            category: preselectedCategory ?? .defaultValue,
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
            localAmount: expense.localAmount,
            rateLocalToBase: expense.rateLocalToBase,
            paymentMethod: expense.paymentMethod,
            exchangeAdjustment: expense.exchangeAdjustment,
            category: expense.category,
            comment: expense.comment ?? ""
        )
    }
    
    private init(
        location: Location,
        expense: Expense?,
        date: Date,
        baseAmount: Double,
        localAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        comment: String
    ) {
        self.location = location
        self.expense = expense
        self.date = date
        self.paymentMethod = paymentMethod
        self.exchangeAdjustment = exchangeAdjustment
        self.category = category
        self.comment = comment
        
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        
        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: location.baseCurrency,
            localCurrency: location.localCurrency,
            rateLocalToBase: rateLocalToBase,
            exchangeAdjustment: exchangeAdjustment
        )
        
        self.amountManager = AmountManager(
            converter: currencyConverter,
            baseAmount: baseAmount,
            localAmount: localAmount
        )
        
        initialSnapshot = Snapshot(
            date: date,
            baseAmount: baseAmount,
            rateLocalToBase: rateLocalToBase,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment,
            category: category,
            comment: comment
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
    
    func updateExchangeAdjustment(_ newAdjustment: Double, currentInput: InputCurrency) {
        exchangeAdjustment = newAdjustment
        syncExchangeAdjustmentAndRecalculate(currentInput: currentInput)
    }
    
    private func syncExchangeAdjustmentAndRecalculate(currentInput: InputCurrency) {
        currencyConverter.updateExchangeAdjustment(exchangeAdjustment)
        amountManager.updateFromRateChange(inputCurrency: currentInput)
    }
    
    // MARK: - Операции с хранилищем
    
    func save(using repository: ExpenseRepository) {
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
        let comment: String?
        
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
            comment: String?
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
