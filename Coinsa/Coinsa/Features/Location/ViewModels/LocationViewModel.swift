//
//  LocationViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class LocationViewModel {
    // MARK: - Stored Properties

    private let location: Location?

    let trip: Trip
    let baseCurrency: Currency

    var name: String
    var startDate: Date
    var endDate: Date
    var localCurrency: Currency
    var rateToBaseCurrency: Double
    var budgetAmounts: [ExpenseCategory: Double]

    // MARK: - Computed Properties

    var isEditing: Bool {
        location != nil
    }

    var locationToEdit: Location? {
        location
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
        return plannedTotalBase / rateToBaseCurrency
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

        if let location {
            name = location.name
            startDate = location.startDate
            endDate = location.endDate
            localCurrency = Currency.from(location.currencyCodeLocal)
            rateToBaseCurrency = location.rateBaseToLocal
        } else {
            name = ""
            startDate = trip.startDate
            endDate = trip.endDate
            localCurrency = baseCurrency
            rateToBaseCurrency = 1.0
        }

        budgetAmounts = Dictionary(uniqueKeysWithValues: ExpenseCategory.allCases.map { ($0, 0) })
        if let location {
            for budget in location.budgets {
                budgetAmounts[budget.category] = budget.amountBase
            }
        }
    }

    // MARK: - Public Methods

    func plannedLocalAmount(for category: ExpenseCategory) -> Double {
        let rate = rateToBaseCurrency
        guard rate > 0 else { return 0 }
        return (budgetAmounts[category] ?? 0) / rate
    }

    func save(using repository: LocationRepository) {
        if let location {
            repository.update(
                location,
                name: name,
                startDate: startDate,
                endDate: endDate,
                currencyLocal: localCurrency,
                rateBaseToLocal: rateToBaseCurrency,
                budgetsByCategory: budgetAmounts
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                currencyLocal: localCurrency,
                rateBaseToLocal: rateToBaseCurrency,
                trip: trip,
                budgetsByCategory: budgetAmounts
            )
        }
    }
}
