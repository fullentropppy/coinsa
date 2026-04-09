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

    private let exchangeRateManager: ExchangeRateManager

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
    var localCurrency: Currency {
        didSet {
            if isHomeLocation {
                exchangeRateManager.cancelRefresh()
                rateLocalToBase = 1
            } else if localCurrency != oldValue {
                requestRateRefresh()
            }
        }
    }
    var rateLocalToBase: Double
    var budgetAmounts: [ExpenseCategory: Double]

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
    
    var plannedBaseTotal: Double {
        budgetAmounts.values.reduce(0, +)
    }

    var plannedLocalTotal: Double {
        return rateLocalToBase > 0 ? (plannedBaseTotal / rateLocalToBase).rounded() : 0
    }
    
    var isRateLoading: Bool {
        exchangeRateManager.isRateLoading
    }
    
    var rateLoadingError: ExchangeRateLoadingError? {
        get { exchangeRateManager.rateLoadingError }
        set { exchangeRateManager.rateLoadingError = newValue }
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
        self.exchangeRateManager = ExchangeRateManager(provider: exchangeRateProvider)
        self.location = location
        self.trip = location?.trip ?? trip
        self.baseCurrency = baseCurrency

        let resolvedName: String
        let resolvedStartDate: Date
        let resolvedEndDate: Date
        let resolvedLocalCurrency: Currency
        let resolvedRateToBaseCurrency: Double

        if let location {
            resolvedName = location.name
            resolvedStartDate = location.startDate
            resolvedEndDate = location.endDate
            resolvedLocalCurrency = Currency.from(location.localCurrencyCode)
            resolvedRateToBaseCurrency = location.rateLocalToBase
        } else {
            resolvedName = ""
            resolvedStartDate = trip.startDate
            resolvedEndDate = trip.endDate
            resolvedLocalCurrency = baseCurrency
            resolvedRateToBaseCurrency = 1.0
        }

        var resolvedBudgetAmounts = Dictionary(
            uniqueKeysWithValues: ExpenseCategory.allCases.map { ($0, 0.0) }
        )
        if let location {
            for budget in location.budgets {
                resolvedBudgetAmounts[budget.category] = budget.baseAmount
            }
        }

        self.name = resolvedName
        self.startDate = resolvedStartDate
        self.endDate = resolvedEndDate
        self.localCurrency = resolvedLocalCurrency
        self.rateLocalToBase = resolvedRateToBaseCurrency
        self.budgetAmounts = resolvedBudgetAmounts

        initialSnapshot = Snapshot(
            name: resolvedName,
            startDate: resolvedStartDate,
            endDate: resolvedEndDate,
            localCurrency: resolvedLocalCurrency,
            rateLocalToBase: resolvedRateToBaseCurrency,
            budgetAmounts: resolvedBudgetAmounts
        )
    }

    // MARK: - Public Methods

    func loadInitialRateIfNeeded() {
        guard !hasLoadedInitialRate && !isEditing && !isHomeLocation else { return }
        
        hasLoadedInitialRate = true
    
        exchangeRateManager.requestRefresh(
            from: localCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            guard let self else { return }
            
            rateLocalToBase = rate
            initialSnapshot = Snapshot(
                name: initialSnapshot.name,
                startDate: initialSnapshot.startDate,
                endDate: initialSnapshot.endDate,
                localCurrency: initialSnapshot.localCurrency,
                rateLocalToBase: rateLocalToBase,
                budgetAmounts: initialSnapshot.budgetAmounts
            )
        }
    }

    func requestRateRefresh() {
        exchangeRateManager.requestRefresh(
            from: localCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            self?.rateLocalToBase = rate
        }
    }
    
    func plannedLocalAmount(for category: ExpenseCategory) -> Double {
        rateLocalToBase > 0 ? ((budgetAmounts[category] ?? 0) / rateLocalToBase).rounded() : 0
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
                budgetsByCategory: budgetAmounts
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                localCurrency: localCurrency,
                rateLocalToBase: rateLocalToBase,
                trip: trip,
                budgetsByCategory: budgetAmounts
            )
        }
    }
    
    // MARK: - Private Methods
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
        let budgetAmounts: [ExpenseCategory: Double]

        // MARK: - Initialization

        init(
            name: String,
            startDate: Date,
            endDate: Date,
            localCurrency: Currency,
            rateLocalToBase: Double,
            budgetAmounts: [ExpenseCategory: Double]
        ) {
            self.name = name.trimmed
            self.startDate = startDate
            self.endDate = endDate
            self.localCurrency = localCurrency
            self.rateLocalToBase = rateLocalToBase
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
                budgetAmounts: viewModel.budgetAmounts
            )
        }
    }
}
