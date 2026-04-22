//
//  LocationEditViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026. 
//

import Foundation
import Observation

@MainActor
@Observable
final class LocationEditViewModel {
    // MARK: - Зависимости
    
    private let currencyConverter: CurrencyConverter
    private let budgetManager: BudgetManager
    
    let location: Location?
    let trip: Trip
    let baseCurrency: Currency
    
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
    
    var availableRange: ClosedRange<Date> {
        min(trip.startDate, startDate)...max(endDate, trip.endDate)
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
            effectiveRateLocalToBase: currencyConverter.effectiveRateLocalToBase.formatted(
                .number.precision(.fractionLength(4))
            ),
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
    
    convenience init(location: Location, baseCurrency: Currency) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            trip: location.trip,
            location: location,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider
        )
    }
    
    convenience init(
        trip: Trip,
        baseCurrency: Currency,
        preselectedExchangeAdjustment: Double? = nil
    ) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            trip: trip,
            location: nil,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider,
            preselectedExchangeAdjustment: preselectedExchangeAdjustment
        )
    }
    
    init(
        trip: Trip,
        location: Location?,
        baseCurrency: Currency,
        exchangeRateProvider: ExchangeRateProvider,
        preselectedExchangeAdjustment: Double? = nil
    ) {
        self.location = location
        self.trip = location?.trip ?? trip
        self.baseCurrency = baseCurrency
        
        let resolvedName: String
        let resolvedStartDate: Date
        let resolvedEndDate: Date
        let resolvedLocalCurrency: Currency
        let resolvedRateLocalToBase: Double
        let resolvedExchangeAdjustment: Double
        let resolvedMajorTimeZone: MajorTimeZone
        
        if let location {
            resolvedName = location.name
            resolvedStartDate = location.startDate
            resolvedEndDate = location.endDate
            resolvedLocalCurrency = Currency.from(location.localCurrencyCode)
            resolvedRateLocalToBase = location.rateLocalToBase
            resolvedExchangeAdjustment = location.exchangeAdjustment
            resolvedMajorTimeZone = location.majorTimeZone
        } else {
            resolvedName = ""
            resolvedStartDate = trip.startDate
            resolvedEndDate = trip.endDate
            resolvedLocalCurrency = baseCurrency
            resolvedRateLocalToBase = 1
            resolvedExchangeAdjustment = preselectedExchangeAdjustment ?? 0
            resolvedMajorTimeZone = MajorTimeZone.defaultValue
        }
        
        var resolvedBudgetAmounts = Dictionary(
            uniqueKeysWithValues: ExpenseCategory.allCases.map { ($0, 0.0) }
        )
        
        if let location {
            for (category, amount) in location.budgetsByCategory() {
                resolvedBudgetAmounts[category] = amount
            }
        }
        
        self.name = resolvedName
        self.startDate = resolvedStartDate
        self.endDate = resolvedEndDate
        self.majorTimeZone = resolvedMajorTimeZone
        self.exchangeAdjustment = resolvedExchangeAdjustment
        
        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: baseCurrency,
            localCurrency: resolvedLocalCurrency,
            rateLocalToBase: resolvedRateLocalToBase,
            exchangeAdjustment: resolvedExchangeAdjustment
        )
        
        var initialBudgets: [ExpenseCategory: Double] = [:]
        if let location {
            initialBudgets = location.budgetsByCategory()
        }
        
        self.budgetManager = BudgetManager(
            converter: currencyConverter,
            initialBudgets: initialBudgets
        )
        
        initialSnapshot = Snapshot(
            name: resolvedName,
            startDate: resolvedStartDate,
            endDate: resolvedEndDate,
            majorTimeZone: resolvedMajorTimeZone,
            localCurrency: resolvedLocalCurrency,
            rateLocalToBase: resolvedRateLocalToBase,
            exchangeAdjustment: resolvedExchangeAdjustment,
            budgetAmounts: resolvedBudgetAmounts
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
    
    func updateExchangeAdjustment(_ newPercentage: Double, currentInput: InputCurrency) {
        exchangeAdjustment = max(0, newPercentage)
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
