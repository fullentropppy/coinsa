//
//  ExpenseEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import CoreLocation
import Foundation
import Observation

/// ViewModel для экрана создания/редактирования траты.
@MainActor
@Observable
final class ExpenseEditViewModel {
    // MARK: - Зависимости
    
    private let homeCurrencyConverter: CurrencyConverter
    private let locationCurrencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    
    let expense: Expense?
    let location: Location
    
    // MARK: - Внутреннее состояние
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRates = false
    private var calculationContext: ExpenseCalculationContext {
        ExpenseCalculationContext(
            homeAmount: homeAmount,
            homeCurrency: homeCurrency,
            expenseCurrency: expenseCurrency,
            rateExpenseToHome: rateExpenseToHome,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment
        )
    }
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var isEdit: Bool {
        expense != nil
    }
    
    var isExpensehomeCurrency: Bool {
        expenseCurrency == homeCurrency
    }
    
    var isExpenseLocationCurrency: Bool {
        expenseCurrency == locationCurrency
    }
    
    var isLocationhomeCurrency: Bool {
        homeCurrency == locationCurrency
    }
    
    var showsRateExpenseToBase: Bool {
        !isExpensehomeCurrency
    }
    
    var showsRateExpenseToLocation: Bool {
        !isExpenseLocationCurrency && !isLocationhomeCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        isEdit ? .expenseNavigationTitleEdit : .expenseNavigationTitleCreate
    }
    
    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        validationMessage == nil
    }

    var validationMessage: LocalizedStringResource? {
        if homeAmount <= 0 {
            .validationAmountRequired
        } else if showsRateExpenseToBase && rateExpenseToHome <= 0
            || showsRateExpenseToLocation && rateExpenseToLocation <= 0 {
            .validationExchangeRateRequired
        } else {
            nil
        }
    }
    
    var homeCurrency: Currency {
        location.homeCurrency
    }
    
    var locationCurrency: Currency {
        location.locationCurrency
    }
    
    var expenseCurrency: Currency {
        homeCurrencyConverter.quoteCurrency
    }
    
    // MARK: - Состояние UI. Общие данные
    
    var date: Date

    var timeZone: TimeZone {
        if let expense, CivilDateTime(date) == CivilDateTime(initialSnapshot.date) {
            expense.timeZone
        } else {
            .current
        }
    }
    
    var category: ExpenseCategory
    var subcategory: ExpenseSubcategory
    var coordinate: Coordinate?
    var comment: String
    
    // MARK: - Состояние UI. Сумма
    
    var amountInputPlaceholder: String? {
        if showsRateExpenseToBase && rateExpenseToHome <= 0
            || showsRateExpenseToLocation && rateExpenseToLocation <= 0 {
            nil
        } else {
            String(localized: .expenseAmountPlaceholder)
        }
    }
    
    var homeAmount: Double {
        get { amountManager.baseAmount }
        set { amountManager.updateBaseAmount(newValue, useExchangeAdjustment: useExchangeAdjustment) }
    }
    
    var expenseAmount: Double {
        get { amountManager.quoteAmount }
        set { amountManager.updateQuoteAmount(newValue, useExchangeAdjustment: useExchangeAdjustment) }
    }
    
    // MARK: - Состояние UI. Курс обмена
    
    var rateExpenseToHome: Double {
        get { homeCurrencyConverter.rateQuoteToBase }
        set { homeCurrencyConverter.updateRate(newValue) }
    }
    
    var rateExpenseToLocation: Double {
        get { locationCurrencyConverter.rateQuoteToBase }
        set { locationCurrencyConverter.updateRate(newValue) }
    }
    
    var isRateExpenseToBaseLoading: Bool {
        homeCurrencyConverter.isRateLoading
    }
    
    var isRateExpenseToLocationLoading: Bool {
        locationCurrencyConverter.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { homeCurrencyConverter.rateLoadingError ?? locationCurrencyConverter.rateLoadingError }
        set {
            homeCurrencyConverter.rateLoadingError = newValue
            locationCurrencyConverter.rateLoadingError = newValue
        }
    }
    
    var adjustedRateDescription: LocalizedStringResource? {
        guard useExchangeAdjustment && exchangeAdjustment > 0 else {
            return nil
        }
        
        if isExpenseLocationCurrency || isLocationhomeCurrency {
            return .expenseAdjustedExchangeRateShort(
                expenseCurrencyCode: expenseCurrency.code,
                effectiveRateExpenseToHome: calculationContext
                    .exchangeRate(from: .expense, to: .home, using: .effective)
                    .numberFormat(fractionLength: 4),
                homeCurrencyCode: homeCurrency.code
            )
        } else {
            return .expenseAdjustedExchangeRateShortDouble(
                expenseCurrencyCode: expenseCurrency.code,
                effectiveRateExpenseToHome: calculationContext
                    .exchangeRate(from: .expense, to: .home, using: .effective)
                    .numberFormat(fractionLength: 4),
                homeCurrencyCode: homeCurrency.code,
                effectiveRateExpenseToLocation: calculationContext
                    .exchangeRate(from: .expense, to: .location, using: .effective)
                    .numberFormat(fractionLength: 4),
                locationCurrencyCode: locationCurrency.code
            )
        }
    }
    
    // MARK: - Состояние UI. Оплата
    
    var paymentMethod: PaymentMethod
    var exchangeAdjustment: Double
    
    var useExchangeAdjustment: Bool {
        !isExpensehomeCurrency && paymentMethod == .card
    }
    
    // MARK: - Инициализация
    
    /// Создает ViewModel для новой траты.
    /// - Parameters:
    ///   - location: Локация траты.
    ///   - preselectedCategory: Предустановленная категория.
    ///   - preselectedSubcategory: Предустановленная подкатегория (определяет категорию, если задана).
    ///   - preselectedPaymentMethod: Предустановленный способ оплаты.
    convenience init(
        forCreateWith location: Location,
        preselectedCategory: ExpenseCategory? = nil,
        preselectedSubcategory: ExpenseSubcategory? = nil,
        preselectedPaymentMethod: PaymentMethod? = nil
    ) {
        let date = CivilDateTime.now.storedDate
        let category = preselectedSubcategory?.category ?? preselectedCategory ?? .defaultValue
        
        self.init(
            location: location,
            expense: nil,
            date: date,
            homeAmount: 0,
            expenseAmount: 0,
            expenseCurrency: location.locationCurrency,
            rateExpenseToHome: location.rateLocationToHome,
            rateExpenseToLocation: 1,
            paymentMethod: preselectedPaymentMethod ?? .card,
            exchangeAdjustment: location.exchangeAdjustment,
            category: category,
            subcategory: preselectedSubcategory ?? .defaultValue(with: category),
            coordinate: nil,
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
            homeAmount: expense.homeAmount,
            expenseAmount: expense.amount(in: .expense),
            expenseCurrency: expense.expenseCurrency,
            rateExpenseToHome: expense.rateExpenseToHome,
            rateExpenseToLocation: expense.rateExpenseToLocation,
            paymentMethod: expense.paymentMethod,
            exchangeAdjustment: expense.exchangeAdjustment,
            category: expense.category,
            subcategory: expense.subcategory,
            coordinate: expense.coordinate,
            comment: expense.comment ?? ""
        )
    }
    
    private init(
        location: Location,
        expense: Expense?,
        date: Date,
        homeAmount: Double,
        expenseAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToHome: Double,
        rateExpenseToLocation: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        coordinate: Coordinate?,
        comment: String
    ) {
        self.location = location
        self.expense = expense
        self.date = date
        self.paymentMethod = paymentMethod
        self.exchangeAdjustment = exchangeAdjustment
        self.category = category
        self.subcategory = subcategory
        self.coordinate = coordinate
        self.comment = comment
        
        let baseExchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        let locationExchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        let normalizedRateExpenseToHome = expenseCurrency == location.homeCurrency ? 1 : rateExpenseToHome
        let normalizedRateExpenseToLocation = expenseCurrency == location.locationCurrency ? 1 : rateExpenseToLocation
        
        self.homeCurrencyConverter = CurrencyConverter(
            exchangeRateProvider: baseExchangeRateProvider,
            baseCurrency: location.homeCurrency,
            quoteCurrency: expenseCurrency,
            rateQuoteToBase: normalizedRateExpenseToHome,
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
            converter: homeCurrencyConverter,
            baseAmount: homeAmount,
            quoteAmount: expenseAmount
        )
        
        initialSnapshot = Snapshot(
            date: date,
            homeAmount: homeAmount,
            expenseCurrency: expenseCurrency,
            rateExpenseToHome: normalizedRateExpenseToHome,
            rateExpenseToLocation: normalizedRateExpenseToLocation,
            paymentMethod: paymentMethod,
            exchangeAdjustment: exchangeAdjustment,
            category: category,
            subcategory: subcategory,
            coordinate: coordinate,
            comment: comment
        )
    }
    
    // MARK: - Операции с валютой
    
    func updateExpenseCurrency(_ newCurrency: Currency, currencyPairSide: CurrencyPairSide) {
        guard newCurrency != expenseCurrency else { return }
        
        homeCurrencyConverter.updateQuoteCurrency(newCurrency) { [weak self] in
            guard let self else { return }
            guard rateExpenseToHome > 0 else { return }
            
            amountManager.updateFromRateChange(
                for: currencyPairSide,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
        
        locationCurrencyConverter.updateQuoteCurrency(newCurrency)
    }
    
    func currency(for currencyPairSide: CurrencyPairSide) -> Currency {
        switch currencyPairSide {
        case .base: homeCurrency
        case .quote: expenseCurrency
        }
    }
    
    // MARK: - Операции с суммой
    
    func amount(for currencyPairSide: CurrencyPairSide) -> Double {
        amountManager.amount(for: currencyPairSide)
    }
    
    func updateAmount(_ newValue: Double, for inputCurrency: CurrencyPairSide) {
        amountManager.updateAmount(
            newValue,
            for: inputCurrency,
            useExchangeAdjustment: useExchangeAdjustment
        )
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRateExpenseToBase(_ newRate: Double, currencyPairSide: CurrencyPairSide) {
        homeCurrencyConverter.updateRate(newRate)
        if newRate > 0 {
            amountManager.updateFromRateChange(
                for: currencyPairSide,
                useExchangeAdjustment: useExchangeAdjustment
            )
        }
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
    
    func requestRateExpenseToBaseRefresh(for inputCurrency: CurrencyPairSide = .base) {
        homeCurrencyConverter.requestRateRefresh { [weak self] _ in
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
        
        homeCurrencyConverter.requestRateRefresh { [weak self] _ in
            self?.syncInitialSnapshotWithCurrentValues()
        }
    }
    
    private func requestInitialRateExpenseToLocationIfNeeded() {
        guard showsRateExpenseToLocation else { return }
        
        locationCurrencyConverter.requestRateRefresh { [weak self] _ in
            self?.syncInitialSnapshotWithCurrentValues()
        }
    }

    private func syncInitialSnapshotWithCurrentValues() {
        initialSnapshot = Snapshot(
            date: initialSnapshot.date,
            homeAmount: initialSnapshot.homeAmount,
            expenseCurrency: initialSnapshot.expenseCurrency,
            rateExpenseToHome: rateExpenseToHome,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethod: initialSnapshot.paymentMethod,
            exchangeAdjustment: initialSnapshot.exchangeAdjustment,
            category: initialSnapshot.category,
            subcategory: initialSnapshot.subcategory,
            coordinate: coordinate,
            comment: initialSnapshot.comment
        )
    }
    
    // MARK: - Операции с категорией
    
    func updateCategory(_ newCategory: ExpenseCategory) {
        category = newCategory
        subcategory = .defaultValue(with: category)
    }
    
    // MARK: - Операции с оплатой
    
    func updatePaymentMethod(_ method: PaymentMethod, currencyPairSide: CurrencyPairSide) {
        paymentMethod = method
        syncExchangeAdjustmentAndRecalculate(currencyPairSide: currencyPairSide)
    }
    
    func updateExchangeAdjustment(_ newAdjustment: Double, currencyPairSide: CurrencyPairSide) {
        exchangeAdjustment = newAdjustment
        syncExchangeAdjustmentAndRecalculate(currencyPairSide: currencyPairSide)
    }
    
    private func syncExchangeAdjustmentAndRecalculate(currencyPairSide: CurrencyPairSide) {
        homeCurrencyConverter.updateExchangeAdjustment(exchangeAdjustment)
        amountManager.updateFromRateChange(for: currencyPairSide, useExchangeAdjustment: useExchangeAdjustment)
    }
    
    // MARK: - Операции с координатами

    func updateCoordinate(_ newCoordinate: Coordinate?) {
        coordinate = newCoordinate
    }

    func applyResolvedCurrentLocation(_ location: CLLocation) {
        guard !isEdit && coordinate == nil else { return }

        coordinate = Coordinate(location)
        syncInitialSnapshotWithCurrentValues()
    }
    
    // MARK: - Операции с хранилищем
    
    private var storedRateExpenseToHome: Double {
        isExpensehomeCurrency ? 1 : rateExpenseToHome
    }
    
    private var storedRateExpenseToLocation: Double {
        isExpenseLocationCurrency ? 1 : rateExpenseToLocation
    }
    
    func save(using repository: ExpenseRepository) {
        if let expense {
            repository.update(
                expense,
                date: date,
                homeAmount: homeAmount,
                expenseCurrency: expenseCurrency,
                rateExpenseToHome: storedRateExpenseToHome,
                rateExpenseToLocation: storedRateExpenseToLocation,
                paymentMethod: paymentMethod,
                exchangeAdjustment: exchangeAdjustment,
                category: category,
                subcategory: subcategory,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude,
                horizontalAccuracy: coordinate?.horizontalAccuracy,
                comment: comment
            )
        } else {
            repository.add(
                date: date,
                homeAmount: homeAmount,
                expenseCurrency: expenseCurrency,
                rateExpenseToHome: storedRateExpenseToHome,
                rateExpenseToLocation: storedRateExpenseToLocation,
                paymentMethod: paymentMethod,
                exchangeAdjustment: exchangeAdjustment,
                category: category,
                subcategory: subcategory,
                location: location,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude,
                horizontalAccuracy: coordinate?.horizontalAccuracy,
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
        let homeAmount: Double
        let expenseCurrency: Currency
        let rateExpenseToHome: Double
        let rateExpenseToLocation: Double
        let paymentMethod: PaymentMethod
        let exchangeAdjustment: Double
        let category: ExpenseCategory
        let subcategory: ExpenseSubcategory
        let coordinate: Coordinate?
        let comment: String?
        
        // MARK: - Инициализация
        
        init(viewModel: ExpenseEditViewModel) {
            self.init(
                date: viewModel.date,
                homeAmount: viewModel.homeAmount,
                expenseCurrency: viewModel.expenseCurrency,
                rateExpenseToHome: viewModel.storedRateExpenseToHome,
                rateExpenseToLocation: viewModel.storedRateExpenseToLocation,
                paymentMethod: viewModel.paymentMethod,
                exchangeAdjustment: viewModel.exchangeAdjustment,
                category: viewModel.category,
                subcategory: viewModel.subcategory,
                coordinate: viewModel.coordinate,
                comment: viewModel.comment
            )
        }
        
        init(
            date: Date,
            homeAmount: Double,
            expenseCurrency: Currency,
            rateExpenseToHome: Double,
            rateExpenseToLocation: Double,
            paymentMethod: PaymentMethod,
            exchangeAdjustment: Double,
            category: ExpenseCategory,
            subcategory: ExpenseSubcategory,
            coordinate: Coordinate?,
            comment: String?
        ) {
            self.date = date
            self.homeAmount = homeAmount
            self.expenseCurrency = expenseCurrency
            self.rateExpenseToHome = rateExpenseToHome
            self.rateExpenseToLocation = rateExpenseToLocation
            self.paymentMethod = paymentMethod
            self.exchangeAdjustment = exchangeAdjustment
            self.category = category
            self.subcategory = subcategory
            self.coordinate = coordinate
            self.comment = comment
        }
    }
}
