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
    // MARK: - Stored Properties
    
    private let currencyConverter: CurrencyConverter
    private let budgetManager: BudgetManager
    
    private var initialSnapshot: Snapshot
    private var hasLoadedInitialRate = false
    
    let location: Location?
    let trip: Trip
    let baseCurrency: Currency
    
    var name: String
    var startDate: Date {
        didSet {
            if endDate < startDate {
                endDate = startDate
            }
        }
    }
    var endDate: Date
    var exchangeAdjustmentPercentage: Double
    
    // MARK: - Computed Properties
    
    var isEditing: Bool {
        location != nil
    }
    
    var navigationTitle: LocalizedStringResource {
        isEditing ? .locationNavigationTitleEdit : .locationNavigationTitleCreate
    }
    
    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }
    
    var canSave: Bool {
        !name.isBlank && startDate <= endDate && rateLocalToBase > 0
    }
    
    var isHomeLocation: Bool {
        baseCurrency == localCurrency
    }
    
    var isRateLoading: Bool { currencyConverter.isRateLoading }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { currencyConverter.rateLoadingError }
        set { currencyConverter.rateLoadingError = newValue }
    }
    
    var localCurrency: Currency {
        get { currencyConverter.localCurrency }
        set { updateLocalCurrency(newValue) }
    }
    
    var rateLocalToBase: Double {
        get { currencyConverter.rateLocalToBase }
        set { currencyConverter.updateRate(newValue) }
    }
    
    private var effectiveExchangeAdjustmentPercentage: Double {
        isHomeLocation ? 0 : max(0, exchangeAdjustmentPercentage)
    }
    
    var plannedBaseTotal: Double {
        budgetManager.totalBaseAmount
    }
    
    var plannedLocalTotal: Double {
        currencyConverter.convertToLocal(fromBase: plannedBaseTotal).rounded()
    }
    
    var budgetAmounts: [ExpenseCategory: Double] {
        budgetManager.budgetsBase
    }
    
    // MARK: - Initialization
    
    convenience init(trip: Trip, baseCurrency: Currency) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            trip: trip,
            location: nil,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider
        )
    }
    
    convenience init(location: Location, baseCurrency: Currency) {
        let exchangeRateProvider = ExchangeRateProvider(service: HexarateService())
        self.init(
            trip: location.trip,
            location: location,
            baseCurrency: baseCurrency,
            exchangeRateProvider: exchangeRateProvider
        )
    }
    
    init(
        trip: Trip,
        location: Location?,
        baseCurrency: Currency,
        exchangeRateProvider: ExchangeRateProvider
    ) {
        self.location = location
        self.trip = location?.trip ?? trip
        self.baseCurrency = baseCurrency
        
        let resolvedName: String
        let resolvedStartDate: Date
        let resolvedEndDate: Date
        let resolvedLocalCurrency: Currency
        let resolvedRateLocalToBase: Double
        let resolvedExchangeAdjustmentPercentage: Double
        
        if let location {
            resolvedName = location.name
            resolvedStartDate = location.startDate
            resolvedEndDate = location.endDate
            resolvedLocalCurrency = Currency.from(location.localCurrencyCode)
            resolvedRateLocalToBase = location.rateLocalToBase
            resolvedExchangeAdjustmentPercentage = location.exchangeAdjustmentPercentage
        } else {
            resolvedName = ""
            resolvedStartDate = trip.startDate
            resolvedEndDate = trip.endDate
            resolvedLocalCurrency = baseCurrency
            resolvedRateLocalToBase = 1
            resolvedExchangeAdjustmentPercentage = 0
        }
        
        var resolvedBudgetAmounts = Dictionary(
            uniqueKeysWithValues: ExpenseCategory.allCases.map { ($0, 0.0) }
        )
        if let location {
            for budget in location.budgets {
                resolvedBudgetAmounts[budget.category] = budget.baseAmount
            }
        }
        
        let normalizedExchangeAdjustmentPercentage = Self.normalizedExchangeAdjustmentPercentage(
            resolvedExchangeAdjustmentPercentage,
            isHomeLocation: resolvedLocalCurrency == baseCurrency
        )

        self.name = resolvedName
        self.startDate = resolvedStartDate
        self.endDate = resolvedEndDate
        self.exchangeAdjustmentPercentage = normalizedExchangeAdjustmentPercentage
        
        self.currencyConverter = CurrencyConverter(
            exchangeRateProvider: exchangeRateProvider,
            baseCurrency: baseCurrency,
            localCurrency: resolvedLocalCurrency,
            rateLocalToBase: resolvedRateLocalToBase,
            exchangeAdjustmentPercentage: normalizedExchangeAdjustmentPercentage
        )
        
        var initialBudgets: [ExpenseCategory: Double] = [:]
        if let location {
            for budget in location.budgets {
                initialBudgets[budget.category] = budget.baseAmount
            }
        }
        
        self.budgetManager = BudgetManager(
            converter: currencyConverter,
            initialBudgets: initialBudgets
        )
        
        initialSnapshot = Snapshot(
            name: resolvedName,
            startDate: resolvedStartDate,
            endDate: resolvedEndDate,
            localCurrency: resolvedLocalCurrency,
            rateLocalToBase: resolvedRateLocalToBase,
            exchangeAdjustmentPercentage: normalizedExchangeAdjustmentPercentage,
            budgetAmounts: resolvedBudgetAmounts
        )
    }

    // MARK: - Public Methods

    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate && !isEditing && !isHomeLocation else { return }
            
        hasLoadedInitialRate = true
    
        currencyConverter.requestRateRefresh { [weak self] rate in
            guard let self else { return }
            
            rateLocalToBase = rate
            initialSnapshot = Snapshot(
                name: initialSnapshot.name,
                startDate: initialSnapshot.startDate,
                endDate: initialSnapshot.endDate,
                localCurrency: initialSnapshot.localCurrency,
                rateLocalToBase: rateLocalToBase,
                exchangeAdjustmentPercentage: exchangeAdjustmentPercentage,
                budgetAmounts: initialSnapshot.budgetAmounts
            )
        }
    }

    func requestRateRefresh() {
        currencyConverter.requestRateRefresh()
    }

    func updateLocalCurrency(_ newCurrency: Currency) {
        currencyConverter.updateLocalCurrency(newCurrency)
    }

    func updateExchangeAdjustmentPercentage(_ newPercentage: Double) {
        exchangeAdjustmentPercentage = max(0, newPercentage)
        currencyConverter.updateExchangeAdjustmentPercentage(effectiveExchangeAdjustmentPercentage)
    }
    
    func budgetBaseAmount(for category: ExpenseCategory) -> Double {
        budgetManager.budgetBase(for: category)
    }
    
    func budgetLocalAmount(for category: ExpenseCategory) -> Double {
        budgetManager.budgetLocal(for: category)
    }
    
    func updateBudget(_ amount: Double, for category: ExpenseCategory, in inputCurrency: InputCurrency) {
        budgetManager.updateBudget(amount, for: category, in: inputCurrency)
    }

    func save(using repository: LocationRepository) {
        if let location {
            repository.update(
                location,
                name: name,
                startDate: startDate,
                endDate: endDate,
                localCurrency: localCurrency,
                rateLocalToBase: rateLocalToBase,
                exchangeAdjustmentPercentage: effectiveExchangeAdjustmentPercentage,
                budgetsByCategory: budgetAmounts
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                localCurrency: localCurrency,
                rateLocalToBase: rateLocalToBase,
                exchangeAdjustmentPercentage: effectiveExchangeAdjustmentPercentage,
                trip: trip,
                budgetsByCategory: budgetAmounts
            )
        }
    }
    
    // MARK: - Private Methods

    private static func normalizedExchangeAdjustmentPercentage(
        _ percentage: Double,
        isHomeLocation: Bool
    ) -> Double {
        isHomeLocation ? 0 : max(0, percentage)
    }
}

// MARK: - Snapshot

private extension LocationEditViewModel {
    struct Snapshot: Equatable {
        // MARK: - Stored Properties

        let name: String
        let startDate: Date
        let endDate: Date
        let localCurrency: Currency
        let rateLocalToBase: Double
        let exchangeAdjustmentPercentage: Double
        let budgetAmounts: [ExpenseCategory: Double]

        // MARK: - Initialization

        init(
            name: String,
            startDate: Date,
            endDate: Date,
            localCurrency: Currency,
            rateLocalToBase: Double,
            exchangeAdjustmentPercentage: Double,
            budgetAmounts: [ExpenseCategory: Double]
        ) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.localCurrency = localCurrency
            self.rateLocalToBase = rateLocalToBase
            self.exchangeAdjustmentPercentage = exchangeAdjustmentPercentage
            self.budgetAmounts = Dictionary(
                uniqueKeysWithValues: ExpenseCategory.allCases.map { category in
                    (category, (budgetAmounts[category] ?? 0).rounded())
                }
            )
        }

        init(viewModel: LocationEditViewModel) {
            self.init(
                name: viewModel.name,
                startDate: viewModel.startDate,
                endDate: viewModel.endDate,
                localCurrency: viewModel.localCurrency,
                rateLocalToBase: viewModel.rateLocalToBase,
                exchangeAdjustmentPercentage: viewModel.effectiveExchangeAdjustmentPercentage,
                budgetAmounts: viewModel.budgetAmounts
            )
        }
    }
}
