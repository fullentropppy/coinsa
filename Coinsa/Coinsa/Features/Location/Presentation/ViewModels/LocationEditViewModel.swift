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
    private let budgetManager: BudgetManager
    
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
        baseCurrency == localCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        isEdit ? .locationNavigationTitleEdit : .locationNavigationTitleCreate
    }
    
    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        !name.isBlank && startDate <= endDate && rateLocalToBase > 0
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
    
    var rateLocalToBase: Double {
        get { currencyConverter.rateLocalToBase }
        set { currencyConverter.updateRate(newValue) }
    }
    
    var isRateLoading: Bool { currencyConverter.isRateLoading }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { currencyConverter.rateLoadingError }
        set { currencyConverter.rateLoadingError = newValue }
    }
    
    var localCurrency: Currency {
        currencyConverter.localCurrency
    }
    
    var adjustedRateDescription: LocalizedStringResource? {
        guard !isHomeLocation && exchangeAdjustment > 0 else {
            return nil
        }
        
        return .locationAdjustedExchangeRate(
            localCurrencyCode: localCurrency.code,
            effectiveRateLocalToBase: currencyConverter.effectiveRateLocalToBase.numberFormat(fractionLength: 4),
            baseCurrencyCode: baseCurrency.code
        )
    }
    
    // MARK: - Состояние UI. Оплата
    
    var exchangeAdjustment: Double
    
    // MARK: - Состояние UI. Бюджет
    
    var budgetAmounts: [ExpenseCategory: Double] {
        budgetManager.budgetsBase
    }
    
    var plannedBaseTotal: Double {
        budgetManager.totalBaseAmount
    }
    
    var plannedLocalTotal: Double {
        budgetManager.totalLocalAmount
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
            localCurrency: trip.baseCurrency,
            rateLocalToBase: 1,
            exchangeAdjustment: preselectedExchangeAdjustment ?? 0,
            budgetAmounts: [:]
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
            localCurrency: location.localCurrency,
            rateLocalToBase: location.rateLocalToBase,
            exchangeAdjustment: location.exchangeAdjustment,
            budgetAmounts: location.budgetsByCategory
        )
    }
    
    private init(
        trip: Trip,
        location: Location?,
        name: String,
        startDate: Date,
        endDate: Date,
        majorTimeZone: MajorTimeZone,
        localCurrency: Currency,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        budgetAmounts: [ExpenseCategory: Double]
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
            localCurrency: localCurrency,
            rateLocalToBase: rateLocalToBase,
            exchangeAdjustment: exchangeAdjustment
        )
        
        self.budgetManager = BudgetManager(
            converter: currencyConverter,
            initialBudgets: budgetAmounts
        )
        
        initialSnapshot = Snapshot(
            name: name,
            startDate: startDate,
            endDate: endDate,
            majorTimeZone: majorTimeZone,
            localCurrency: localCurrency,
            rateLocalToBase: rateLocalToBase,
            exchangeAdjustment: exchangeAdjustment,
            budgetAmounts: budgetAmounts
        )
    }
    
    // MARK: - Операции с валютой
    
    func updateLocalCurrency(_ newCurrency: Currency, currentInput: InputCurrency) {
        guard newCurrency != localCurrency else { return }
        
        currencyConverter.updateLocalCurrency(newCurrency) { [weak self] in
            self?.budgetManager.updateFromRateChange(inputCurrency: currentInput)
        }
    }
    
    // MARK: - Операции с курсом обмена
    
    func updateRate(_ newRate: Double, currentInput: InputCurrency) {
        currencyConverter.updateRate(newRate)
        budgetManager.updateFromRateChange(inputCurrency: currentInput)
    }
    
    func requestRateRefresh(for inputCurrency: InputCurrency = .base) {
        currencyConverter.requestRateRefresh { [weak self] _ in
            self?.budgetManager.updateFromRateChange(inputCurrency: inputCurrency)
        }
    }
    
    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate && !isEdit && !isHomeLocation else { return }
        
        hasLoadedInitialRate = true
        
        currencyConverter.requestRateRefresh { [weak self] rate in
            guard let self else { return }
            
            rateLocalToBase = rate
            initialSnapshot = Snapshot(
                name: initialSnapshot.name,
                startDate: initialSnapshot.startDate,
                endDate: initialSnapshot.endDate,
                majorTimeZone: initialSnapshot.majorTimeZone,
                localCurrency: initialSnapshot.localCurrency,
                rateLocalToBase: rateLocalToBase,
                exchangeAdjustment: exchangeAdjustment,
                budgetAmounts: initialSnapshot.budgetAmounts
            )
        }
    }
    
    // MARK: - Операции с оплатой
    
    func updateExchangeAdjustment(_ newAdjustment: Double, currentInput: InputCurrency) {
        exchangeAdjustment = newAdjustment
        budgetManager.updateFromRateChange(inputCurrency: currentInput)
        currencyConverter.updateExchangeAdjustment(exchangeAdjustment)
    }
    
    // MARK: - Операции с бюджетом
    
    func updateBudget(_ amount: Double, for category: ExpenseCategory, in inputCurrency: InputCurrency) {
        budgetManager.updateBudget(amount, for: category, in: inputCurrency)
    }
    
    func budgetBaseAmount(for category: ExpenseCategory) -> Double {
        budgetManager.budgetBase(for: category)
    }
    
    func budgetLocalAmount(for category: ExpenseCategory) -> Double {
        budgetManager.budgetLocal(for: category)
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
                localCurrency: localCurrency,
                rateLocalToBase: rateLocalToBase,
                exchangeAdjustment: exchangeAdjustment,
                budgetsByCategory: budgetAmounts
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                majorTimeZone: majorTimeZone,
                localCurrency: localCurrency,
                rateLocalToBase: rateLocalToBase,
                exchangeAdjustment: exchangeAdjustment,
                trip: trip,
                budgetsByCategory: budgetAmounts
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
        let localCurrency: Currency
        let rateLocalToBase: Double
        let exchangeAdjustment: Double
        let budgetAmounts: [ExpenseCategory: Double]
        
        // MARK: - Инициализация
        
        init(viewModel: LocationEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                majorTimeZone: viewModel.majorTimeZone,
                localCurrency: viewModel.localCurrency,
                rateLocalToBase: viewModel.rateLocalToBase,
                exchangeAdjustment: viewModel.exchangeAdjustment,
                budgetAmounts: viewModel.budgetAmounts
            )
        }
        
        init(
            name: String,
            startDate: Date,
            endDate: Date,
            majorTimeZone: MajorTimeZone,
            localCurrency: Currency,
            rateLocalToBase: Double,
            exchangeAdjustment: Double,
            budgetAmounts: [ExpenseCategory: Double]
        ) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.majorTimeZone = majorTimeZone
            self.localCurrency = localCurrency
            self.rateLocalToBase = rateLocalToBase
            self.exchangeAdjustment = exchangeAdjustment
            self.budgetAmounts = Dictionary(
                uniqueKeysWithValues: ExpenseCategory.allCases.map { category in
                    (category, (budgetAmounts[category] ?? 0).rounded())
                }
            )
        }
    }
}
