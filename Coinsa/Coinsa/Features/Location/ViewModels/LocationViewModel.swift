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
    let baseCurrencyCode: String

    var name: String
    var startDate: Date
    var endDate: Date
    var locationCurrencyCode: String
    var exchangeRateLocationToBaseCurrency: Double
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

    // MARK: - Initialization

    init(
        trip: Trip,
        location: Location?,
        baseCurrencyCode: String = Locale.current.currency?.identifier ?? "USD"
    ) {
        self.location = location
        self.trip = location?.trip ?? trip
        self.baseCurrencyCode = baseCurrencyCode

        if let location {
            name = location.name
            startDate = location.startDate
            endDate = location.endDate
            locationCurrencyCode = location.locationCurrencyCode
            exchangeRateLocationToBaseCurrency = location.exchangeRateLocationToBaseCurrency
        } else {
            name = ""
            startDate = trip.startDate
            endDate = trip.endDate
            locationCurrencyCode = baseCurrencyCode
            exchangeRateLocationToBaseCurrency = 1.0
        }

        budgetAmounts = Dictionary(uniqueKeysWithValues: ExpenseCategory.allCases.map { ($0, 0) })
        if let location {
            for budget in location.budgets {
                budgetAmounts[budget.category] = budget.amountInBaseCurrency
            }
        }
    }

    // MARK: - Public Methods

    func save(using store: LocationStore) {
        if let location {
            store.update(
                location,
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrencyCode: locationCurrencyCode,
                exchangeRateLocationToBaseCurrency: exchangeRateLocationToBaseCurrency,
                budgetsByCategory: budgetAmounts
            )
        } else {
            store.add(
                name: name,
                startDate: startDate,
                endDate: endDate,
                locationCurrencyCode: locationCurrencyCode,
                exchangeRateLocationToBaseCurrency: exchangeRateLocationToBaseCurrency,
                trip: trip,
                budgetsByCategory: budgetAmounts
            )
        }
    }
}
