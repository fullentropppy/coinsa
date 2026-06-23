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
    var majorTimeZone: MajorTimeZone
    
    var availableRangeForStartDate: ClosedRange<Date> {
        min(trip.startDate, startDate)...max(endDate, trip.endDate)
    }
    
    var availableRangeForEndDate: ClosedRange<Date> {
        startDate...availableRangeForStartDate.upperBound
    }
    
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
    
    var adjustedRateDescription: LocalizedStringResource? {
        guard !isHomeLocation && exchangeAdjustment > 0 else {
            return nil
        }
        
        return .locationAdjustedExchangeRate(
            localCurrencyCode: locationCurrency.code,
            effectiveRateLocalToBase: currencyConverter.effectiveRateBaseToQuote.numberFormat(fractionLength: 4),
            baseCurrencyCode: baseCurrency.code
        )
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
            startDate: trip.startDate,
            endDate: trip.endDate,
            majorTimeZone: .defaultValue,
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
            startDate: location.startDate,
            endDate: location.endDate,
            majorTimeZone: location.majorTimeZone,
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
        majorTimeZone: MajorTimeZone,
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
        self.majorTimeZone = majorTimeZone
        self.exchangeAdjustment = exchangeAdjustment
        
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        
        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: trip.baseCurrency,
            quoteCurrency: locationCurrency,
            rateBaseToQuote: rateLocationToBase,
            exchangeAdjustment: exchangeAdjustment
        )
        
        self.amountManager = AmountManager(
            converter: currencyConverter,
            baseAmount: budget,
            quoteAmount: currencyConverter.convertToQuote(fromBase: budget)
        )
        
        initialSnapshot = Snapshot(
            name: name,
            startDate: startDate,
            endDate: endDate,
            majorTimeZone: majorTimeZone,
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
            amountManager.updateFromRateChange(for: currencySide(for: currentInput))
        }
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRate(_ newRate: Double, currentInput: CurrencyContext) {
        currencyConverter.updateRate(newRate)
        amountManager.updateFromRateChange(for: currencySide(for: currentInput))
    }
    
    func requestRateRefresh(for inputCurrency: CurrencyContext = .base) {
        currencyConverter.requestRateRefresh { [weak self] _ in
            guard let self else { return }
            amountManager.updateFromRateChange(for: currencySide(for: inputCurrency))
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
                majorTimeZone: initialSnapshot.majorTimeZone,
                locationCurrency: initialSnapshot.locationCurrency,
                rateLocationToBase: rateLocationToBase,
                exchangeAdjustment: exchangeAdjustment,
                budget: initialSnapshot.budget
            )
        }
    }
    
    // MARK: - Операции с оплатой
    
    func updateExchangeAdjustment(_ newAdjustment: Double, currentInput: CurrencyContext) {
        exchangeAdjustment = newAdjustment
        currencyConverter.updateExchangeAdjustment(exchangeAdjustment)
        amountManager.updateFromRateChange(for: currencySide(for: currentInput))
    }
    
    // MARK: - Операции с бюджетом
    
    func updateBudget(_ amount: Double, in inputCurrency: CurrencyContext) {
        amountManager.updateAmount(amount, for: currencySide(for: inputCurrency))
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
                majorTimeZone: majorTimeZone,
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
                majorTimeZone: majorTimeZone,
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
        let majorTimeZone: MajorTimeZone
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
                majorTimeZone: viewModel.majorTimeZone,
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
            majorTimeZone: MajorTimeZone,
            locationCurrency: Currency,
            rateLocationToBase: Double,
            exchangeAdjustment: Double,
            budget: Double
        ) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.majorTimeZone = majorTimeZone
            self.locationCurrency = locationCurrency
            self.rateLocationToBase = rateLocationToBase
            self.exchangeAdjustment = exchangeAdjustment
            self.budget = budget.rounded()
        }
    }
}
