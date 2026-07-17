//
//  LocationEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import Observation

/// ViewModel для экрана создания/редактирования локации.
@MainActor
@Observable
final class LocationEditViewModel {
    // MARK: - Зависимости
    
    private let currencyConverter: CurrencyConverter
    private let amountManager: AmountManager
    
    let trip: Trip
    let location: Location?
    
    // MARK: - Внутреннее состояние
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRate = false
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var isEdit: Bool {
        location != nil
    }
    
    var isHomeLocation: Bool {
        baseCurrency == locationCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        isEdit ? .locationNavigationTitleEdit : .locationNavigationTitleCreate
    }
    
    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        !name.isBlank && startDate <= endDate && rateLocationToBase > 0
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
    
    var baseCurrency: Currency {
        trip.baseCurrency
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
    
    var rateLocationToBase: Double {
        get { currencyConverter.rateBaseToQuote }
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
    
    var budgetBaseAmount: Double {
        amountManager.baseAmount
    }
    
    var budgetLocalAmount: Double {
        amountManager.quoteAmount
    }
    
    // MARK: - Инициализация
    
    /// Создает ViewModel для новой локации.
    /// - Parameters:
    ///   - trip: Родительская поездка.
    ///   - preselectedExchangeAdjustment: Предустановленная корректировка курса.
    convenience init(forCreateWith trip: Trip, preselectedExchangeAdjustment: Double? = nil) {
        self.init(
            trip: trip,
            location: nil,
            name: "",
            startDate: trip.startPlainDate.storedDate,
            endDate: trip.endPlainDate.storedDate,
            locationCurrency: trip.baseCurrency,
            rateLocationToBase: 1,
            exchangeAdjustment: preselectedExchangeAdjustment ?? 0,
            budget: 0
        )
    }
    
    /// Создает ViewModel для редактирования существующей локации.
    /// - Parameter location: Редактируемая локация.
    convenience init(forEdit location: Location) {
        self.init(
            trip: location.trip!,
            location: location,
            name: location.name,
            startDate: location.startPlainDate.storedDate,
            endDate: location.endPlainDate.storedDate,
            locationCurrency: location.locationCurrency,
            rateLocationToBase: location.rateLocationToBase,
            exchangeAdjustment: location.exchangeAdjustment,
            budget: location.budget
        )
    }
    
    private init(
        trip: Trip,
        location: Location?,
        name: String,
        startDate: Date,
        endDate: Date,
        locationCurrency: Currency,
        rateLocationToBase: Double,
        exchangeAdjustment: Double,
        budget: Double
    ) {
        self.trip = trip
        self.location = location
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.exchangeAdjustment = exchangeAdjustment.nonNegative
        
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        
        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: trip.baseCurrency,
            quoteCurrency: locationCurrency,
            rateBaseToQuote: rateLocationToBase
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
            rateLocationToBase: rateLocationToBase,
            exchangeAdjustment: exchangeAdjustment,
            budget: budget
        )
    }
    
    // MARK: - Операции с валютой
    
    func updateLocalCurrency(_ newCurrency: Currency, currentInput: CurrencyContext) {
        guard newCurrency != locationCurrency else { return }
        
        currencyConverter.updateQuoteCurrency(newCurrency) { [weak self] in
            guard let self else { return }
            amountManager.updateFromRateChange(
                for: currencySide(for: currentInput),
                useExchangeAdjustment: false
            )
        }
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRate(_ newRate: Double, currentInput: CurrencyContext) {
        currencyConverter.updateRate(newRate)
        amountManager.updateFromRateChange(
            for: currencySide(for: currentInput),
            useExchangeAdjustment: false
        )
    }
    
    func requestRateRefresh(for inputCurrency: CurrencyContext = .base) {
        currencyConverter.requestRateRefresh { [weak self] _ in
            guard let self else { return }
            amountManager.updateFromRateChange(
                for: currencySide(for: inputCurrency),
                useExchangeAdjustment: false
            )
        }
    }
    
    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate && !isEdit && !isHomeLocation else { return }
        
        hasLoadedInitialRate = true
        
        currencyConverter.requestRateRefresh { [weak self] rate in
            guard let self else { return }
            
            rateLocationToBase = rate
            initialSnapshot = Snapshot(
                name: initialSnapshot.name,
                startDate: initialSnapshot.startDate,
                endDate: initialSnapshot.endDate,
                locationCurrency: initialSnapshot.locationCurrency,
                rateLocationToBase: rateLocationToBase,
                exchangeAdjustment: 1,
                budget: initialSnapshot.budget
            )
        }
    }
    
    // MARK: - Операции с бюджетом
    
    func updateBudget(_ amount: Double, in inputCurrency: CurrencyContext) {
        amountManager.updateAmount(
            amount,
            for: currencySide(for: inputCurrency),
            useExchangeAdjustment: false
        )
    }
    
    private func currencySide(for currency: CurrencyContext) -> CurrencySide {
        switch currency {
        case .base:
            return .base
        case .location, .expense:
            return .quote
        }
    }
    
    // MARK: - Операции с хранилищем
    
    func save(using repository: LocationRepository) {
        if let location {
            repository.update(
                location,
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrency: locationCurrency,
                rateLocationToBase: rateLocationToBase,
                exchangeAdjustment: exchangeAdjustment,
                budget: budgetBaseAmount
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrency: locationCurrency,
                rateLocationToBase: rateLocationToBase,
                exchangeAdjustment: exchangeAdjustment,
                budget: budgetBaseAmount,
                trip: trip,
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
        let rateLocationToBase: Double
        let exchangeAdjustment: Double
        let budget: Double
        
        // MARK: - Инициализация
        
        init(viewModel: LocationEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                locationCurrency: viewModel.locationCurrency,
                rateLocationToBase: viewModel.rateLocationToBase,
                exchangeAdjustment: viewModel.exchangeAdjustment,
                budget: viewModel.budgetBaseAmount
            )
        }
        
        init(
            name: String,
            startDate: Date,
            endDate: Date,
            locationCurrency: Currency,
            rateLocationToBase: Double,
            exchangeAdjustment: Double,
            budget: Double
        ) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.locationCurrency = locationCurrency
            self.rateLocationToBase = rateLocationToBase
            self.exchangeAdjustment = exchangeAdjustment
            self.budget = budget.rounded()
        }
    }
}
