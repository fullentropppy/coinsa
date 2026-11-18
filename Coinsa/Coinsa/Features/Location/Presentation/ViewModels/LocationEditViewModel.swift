//
//  LocationEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import Observation
import SwiftData

/// ViewModel для экрана создания/редактирования локации.
@MainActor
@Observable
final class LocationEditViewModel {
    // MARK: - Зависимости
    
    private let currencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    private let allowsRateRequests: Bool
    
    let trip: Trip
    let location: Location?
    
    // MARK: - Внутреннее состояние
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRate = false
    private var budgetInputSide: CurrencyPairSide = .base
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var isEdit: Bool {
        location != nil
    }
    
    var isHomeLocation: Bool {
        homeCurrency == locationCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        isEdit ? .locationNavigationTitleEdit : .locationNavigationTitleCreate
    }
    
    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        validationMessage == nil
    }

    var validationMessage: LocalizedStringResource? {
        if name.isBlank {
            .validationLocationNameRequired
        } else if rateLocationToHome <= 0 {
            .validationExchangeRateRequired
        } else {
            nil
        }
    }
    
    var totalDays: Int {
        endDate.days(from: startDate) + 1
    }
    
    var availableRangeForStartDate: ClosedRange<Date> {
        min(trip.startPlainDate.storedDate, startDate)...max(endDate, trip.endPlainDate.storedDate)
    }
    
    var availableRangeForEndDate: ClosedRange<Date> {
        startDate...availableRangeForStartDate.upperBound
    }
    
    var hasExpenses: Bool {
        location?.hasExpenses ?? false
    }
    
    var homeCurrency: Currency {
        trip.homeCurrency
    }
    
    // MARK: - Состояние UI. Общие данные
    
    var name: String
    var startDate: Date {
        didSet {
            if endDate < startDate {
                endDate = startDate
            }
        }
    }
    var endDate: Date
    
    // MARK: - Состояние UI. Курс обмена
    
    var rateLocationToHome: Double {
        get { currencyConverter.rateQuoteToBase }
        set { currencyConverter.updateRate(newValue) }
    }
    
    var isRateLoading: Bool { currencyConverter.isRateLoading }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { currencyConverter.rateLoadingError }
        set { currencyConverter.rateLoadingError = newValue }
    }
    
    var locationCurrency: Currency {
        currencyConverter.quoteCurrency
    }
    
    // MARK: - Состояние UI. Оплата
    
    var exchangeAdjustment: Double
    
    // MARK: - Состояние UI. Бюджет
    
    var budgetHomeAmount: Double {
        amountManager.baseAmount
    }
    
    var budgetLocationAmount: Double {
        amountManager.quoteAmount
    }
    
    // MARK: - Инициализация
    
    /// Создает ViewModel для новой локации.
    /// - Parameters:
    ///   - trip: Родительская поездка.
    ///   - preselectedExchangeAdjustment: Предустановленная корректировка курса.
    ///   - allowsRateRequests: Разрешать сетевые запросы курсов; отключается для изолированных превью.
    convenience init(
        forCreateWith trip: Trip,
        preselectedExchangeAdjustment: Double? = nil,
        allowsRateRequests: Bool = true
    ) {
        self.init(
            trip: trip,
            location: nil,
            name: "",
            startDate: trip.startPlainDate.storedDate,
            endDate: trip.endPlainDate.storedDate,
            locationCurrency: trip.homeCurrency,
            rateLocationToHome: 1,
            exchangeAdjustment: preselectedExchangeAdjustment ?? 0,
            budget: 0,
            allowsRateRequests: allowsRateRequests
        )
    }
    
    /// Создает черновик локации; возвращает nil, если локация или родительская поездка недоступны.
    /// - Parameters:
    ///   - location: Редактируемая локация.
    ///   - allowsRateRequests: Разрешать сетевые запросы курсов; отключается для изолированных превью.
    convenience init?(forEdit location: Location, allowsRateRequests: Bool = true) {
        guard !location.isDeleted, let trip = location.trip, !trip.isDeleted else { return nil }

        self.init(
            trip: trip,
            location: location,
            name: location.name,
            startDate: location.startPlainDate.storedDate,
            endDate: location.endPlainDate.storedDate,
            locationCurrency: location.locationCurrency,
            rateLocationToHome: location.rateLocationToHome,
            exchangeAdjustment: location.exchangeAdjustment,
            budget: location.budget,
            allowsRateRequests: allowsRateRequests
        )
    }
    
    /// Создает черновик локации, конвертер валют и исходный снимок для определения изменений.
    /// - Parameters:
    ///   - trip: Родительская поездка.
    ///   - location: Исходная локация или nil при создании.
    ///   - name: Начальное название.
    ///   - startDate: Начальная календарная дата пребывания.
    ///   - endDate: Конечная календарная дата пребывания.
    ///   - locationCurrency: Валюта локации.
    ///   - rateLocationToHome: Начальный курс к домашней валюте.
    ///   - exchangeAdjustment: Начальная корректировка курса.
    ///   - budget: Начальный бюджет в домашней валюте.
    ///   - allowsRateRequests: Разрешать сетевые запросы курсов.
    private init(
        trip: Trip,
        location: Location?,
        name: String,
        startDate: Date,
        endDate: Date,
        locationCurrency: Currency,
        rateLocationToHome: Double,
        exchangeAdjustment: Double,
        budget: Double,
        allowsRateRequests: Bool
    ) {
        self.trip = trip
        self.location = location
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.exchangeAdjustment = exchangeAdjustment.nonNegative
        self.allowsRateRequests = allowsRateRequests
        
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        
        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: trip.homeCurrency,
            quoteCurrency: locationCurrency,
            rateQuoteToBase: rateLocationToHome
        )
        
        self.amountManager = AmountManager(
            converter: currencyConverter,
            baseAmount: budget,
            quoteAmount: currencyConverter.convertToQuote(fromBase: budget, useExchangeAdjustment: false)
        )
        
        initialSnapshot = Snapshot(
            name: name,
            startDate: startDate,
            endDate: endDate,
            locationCurrency: locationCurrency,
            rateLocationToHome: rateLocationToHome,
            exchangeAdjustment: exchangeAdjustment,
            budget: budget
        )
    }
    
    // MARK: - Операции с валютой
    
    func updateLocationCurrency(_ newCurrency: Currency, currentInput: CurrencyContext) {
        guard newCurrency != locationCurrency else { return }
        budgetInputSide = currencyPairSide(for: currentInput)

        guard allowsRateRequests else {
            currencyConverter.setCurrencies(base: homeCurrency, quote: newCurrency)
            amountManager.updateFromRateChange(for: budgetInputSide, useExchangeAdjustment: false)
            return
        }
        
        currencyConverter.updateQuoteCurrency(newCurrency) { [weak self] in
            guard let self else { return }
            guard rateLocationToHome > 0 else { return }
            
            amountManager.updateFromRateChange(
                for: budgetInputSide,
                useExchangeAdjustment: false
            )
        }
    }
    
    // MARK: - Операции с курсом обмена

    /// Восстанавливает сохраненные валюту и курс после запрета смены валюты, сохраняя домашнюю сумму черновика.
    func restoreStoredLocationCurrency() {
        guard let location else { return }

        currencyConverter.cancelRateRefresh()
        currencyConverter.setCurrencies(base: homeCurrency, quote: location.locationCurrency)
        currencyConverter.updateRate(location.rateLocationToHome)
        amountManager.updateFromRateChange(for: .base, useExchangeAdjustment: false)
    }
    
    func updateRate(_ newRate: Double, currentInput: CurrencyContext) {
        currencyConverter.updateRate(newRate)
        if newRate > 0 {
            amountManager.updateFromRateChange(
                for: currencyPairSide(for: currentInput),
                useExchangeAdjustment: false
            )
        }
    }
    
    func requestRateRefresh(for inputCurrency: CurrencyContext = .home) {
        guard allowsRateRequests else { return }
        budgetInputSide = currencyPairSide(for: inputCurrency)
        currencyConverter.requestRateRefresh { [weak self] _ in
            guard let self else { return }
            amountManager.updateFromRateChange(
                for: budgetInputSide,
                useExchangeAdjustment: false
            )
        }
    }
    
    func loadInitialRateIfNeeded() {
        guard allowsRateRequests, !hasLoadedInitialRate && !isEdit && !isHomeLocation else { return }
        
        hasLoadedInitialRate = true
        
        currencyConverter.requestRateRefresh { [weak self] rate in
            guard let self else { return }
            
            rateLocationToHome = rate
            amountManager.updateFromRateChange(for: budgetInputSide, useExchangeAdjustment: false)
            initialSnapshot = Snapshot(
                name: initialSnapshot.name,
                startDate: initialSnapshot.startDate,
                endDate: initialSnapshot.endDate,
                locationCurrency: initialSnapshot.locationCurrency,
                rateLocationToHome: rateLocationToHome,
                exchangeAdjustment: 1,
                budget: initialSnapshot.budget
            )
        }
    }
    
    // MARK: - Операции с бюджетом
    
    func updateBudget(_ amount: Double, in inputCurrency: CurrencyContext) {
        budgetInputSide = currencyPairSide(for: inputCurrency)
        amountManager.updateAmount(
            amount,
            for: currencyPairSide(for: inputCurrency),
            useExchangeAdjustment: false
        )
    }
    
    private func currencyPairSide(for currency: CurrencyContext) -> CurrencyPairSide {
        switch currency {
        case .home:
            return .base
        case .location, .expense:
            return .quote
        }
    }
    
    // MARK: - Операции с хранилищем
    
    func save(using repository: LocationRepository) throws {
        if let location {
            try repository.update(
                location,
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrency: locationCurrency,
                rateLocationToHome: rateLocationToHome,
                exchangeAdjustment: exchangeAdjustment,
                budget: budgetHomeAmount
            )
        } else {
            try repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrency: locationCurrency,
                rateLocationToHome: rateLocationToHome,
                exchangeAdjustment: exchangeAdjustment,
                budget: budgetHomeAmount,
                trip: trip
            )
        }
    }
}

// MARK: - Внутренние типы

private extension LocationEditViewModel {
    /// Снимок состояния для отслеживания изменений.
    struct Snapshot: Equatable {
        // MARK: - Свойства
        
        let name: String
        let startDate: Date
        let endDate: Date
        let locationCurrency: Currency
        let rateLocationToHome: Double
        let exchangeAdjustment: Double
        let budget: Double
        
        // MARK: - Инициализация
        
        /// Фиксирует текущее состояние редактора локации для сравнения изменений.
        init(viewModel: LocationEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                locationCurrency: viewModel.locationCurrency,
                rateLocationToHome: viewModel.rateLocationToHome,
                exchangeAdjustment: viewModel.exchangeAdjustment,
                budget: viewModel.budgetHomeAmount
            )
        }
        
        /// Создает снимок локации, удаляя крайние пробелы из названия.
        init(
            name: String,
            startDate: Date,
            endDate: Date,
            locationCurrency: Currency,
            rateLocationToHome: Double,
            exchangeAdjustment: Double,
            budget: Double
        ) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.locationCurrency = locationCurrency
            self.rateLocationToHome = rateLocationToHome
            self.exchangeAdjustment = exchangeAdjustment
            self.budget = budget.rounded()
        }
    }
}
