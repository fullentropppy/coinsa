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

    private let initialSnapshot: Snapshot
    
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
    var localCurrency: Currency
    var rateToBaseCurrency: Double
    var budgetAmounts: [ExpenseCategory: Double]

    // MARK: - Computed Properties

    var isEditing: Bool {
        location != nil
    }

    var navigationTitle: String {
        String(localized: isEditing
            ? "location.navigationTitle.edit"
            : "location.navigationTitle.create"
        )
    }

    var plannedTotalBase: Double {
        budgetAmounts.values.reduce(0, +)
    }

    var plannedTotalLocal: Double {
        guard rateToBaseCurrency > 0 else { return 0 }
        return (plannedTotalBase / rateToBaseCurrency).rounded()
    }

    var hasChanges: Bool {
        Snapshot(viewModel: self) != initialSnapshot
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && startDate <= endDate
        && rateToBaseCurrency > 0
    }

    // MARK: - Initialization

    convenience init(trip: Trip, baseCurrency: Currency) {
        self.init(trip: trip, location: nil, baseCurrency: baseCurrency)
    }

    convenience init(location: Location, baseCurrency: Currency) {
        self.init(trip: location.trip, location: location, baseCurrency: baseCurrency)
    }
    
    init(trip: Trip, location: Location?, baseCurrency: Currency) {
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
            resolvedLocalCurrency = Currency.from(location.currencyCodeLocal)
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
                resolvedBudgetAmounts[budget.category] = budget.amountBase
            }
        }

        name = resolvedName
        startDate = resolvedStartDate
        endDate = resolvedEndDate
        localCurrency = resolvedLocalCurrency
        rateToBaseCurrency = resolvedRateToBaseCurrency
        budgetAmounts = resolvedBudgetAmounts

        initialSnapshot = Snapshot(
            name: resolvedName,
            startDate: resolvedStartDate,
            endDate: resolvedEndDate,
            localCurrency: resolvedLocalCurrency,
            rateToBaseCurrency: resolvedRateToBaseCurrency,
            budgetAmounts: resolvedBudgetAmounts
        )
    }

    // MARK: - Public Methods

    func plannedLocalAmount(for category: ExpenseCategory) -> Double {
        let rate = rateToBaseCurrency
        guard rate > 0 else { return 0 }
        return ((budgetAmounts[category] ?? 0) / rate).rounded()
    }

    func save(using repository: LocationRepository) {
        if let location {
            repository.update(
                location,
                name: name,
                startDate: startDate,
                endDate: endDate,
                currencyLocal: localCurrency,
                rateLocalToBase: rateToBaseCurrency,
                budgetsByCategory: budgetAmounts
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                currencyLocal: localCurrency,
                rateLocalToBase: rateToBaseCurrency,
                trip: trip,
                budgetsByCategory: budgetAmounts
            )
        }
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
        let rateToBaseCurrency: Double
        let budgetAmounts: [ExpenseCategory: Double]

        // MARK: - Initialization

        init(
            name: String,
            startDate: Date,
            endDate: Date,
            localCurrency: Currency,
            rateToBaseCurrency: Double,
            budgetAmounts: [ExpenseCategory: Double]
        ) {
            self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            self.startDate = startDate
            self.endDate = endDate
            self.localCurrency = localCurrency
            self.rateToBaseCurrency = rateToBaseCurrency.rounded(to: 6)
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
                rateToBaseCurrency: viewModel.rateToBaseCurrency,
                budgetAmounts: viewModel.budgetAmounts
            )
        }
    }
}
