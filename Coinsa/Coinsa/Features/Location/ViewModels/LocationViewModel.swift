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
    var currency: Currency
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
        String(
            localized: isEditing
                ? "location.editing.navigationTitle.editing"
                : "location.editing.navigationTitle.creating"
        )
    }

    var plannedTotalBase: Double {
        budgetAmounts.values.reduce(0, +)
    }

    var plannedTotalLocal: Double {
        let rate = rateToBaseCurrency
        guard rate > 0 else { return 0 }
        return plannedTotalBase / rate
    }

    // MARK: - Initialization

    init(trip: Trip, location: Location?, baseCurrency: Currency) {
        self.location = location
        self.trip = location?.trip ?? trip
        self.baseCurrency = baseCurrency

        if let location {
            name = location.name
            startDate = location.startDate
            endDate = location.endDate
            currency = Currency.from(code: location.currencyCode)
            rateToBaseCurrency = location.rateToBaseCurrency
        } else {
            name = ""
            startDate = trip.startDate
            endDate = trip.endDate
            currency = baseCurrency
            rateToBaseCurrency = 1.0
        }

        budgetAmounts = Dictionary(uniqueKeysWithValues: ExpenseCategory.allCases.map { ($0, 0) })
        if let location {
            for budget in location.budgets {
                budgetAmounts[budget.category] = budget.amountInBaseCurrency
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
                locationCurrency: currency,
                exchangeRateLocationToBaseCurrency: rateToBaseCurrency,
                budgetsByCategory: budgetAmounts
            )
        } else {
            repository.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrency: currency,
                exchangeRateLocationToBaseCurrency: rateToBaseCurrency,
                trip: trip,
                budgetsByCategory: budgetAmounts
            )
        }
    }
}
