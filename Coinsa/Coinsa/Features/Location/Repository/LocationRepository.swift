//
//  LocationRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation
import SwiftData

@MainActor
struct LocationRepository {
    // MARK: - Stored Properties

    let context: ModelContext

    // MARK: - Public Methods
    
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        locationCurrency: Currency,
        exchangeRateLocationToBaseCurrency: Double,
        trip: Trip,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        let location = Location(
            name: name,
            startDate: startDate,
            endDate: endDate,
            locationCurrencyCode: locationCurrency.code,
            exchangeRateLocationToBaseCurrency: exchangeRateLocationToBaseCurrency,
            trip: trip,
            budgets: [],
            expenses: []
        )

        applyBudgets(budgetsByCategory, to: location)
        context.insert(location)
    }

    func update(
        _ location: Location,
        name: String,
        startDate: Date,
        endDate: Date,
        locationCurrency: Currency,
        exchangeRateLocationToBaseCurrency: Double,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        location.name = name
        location.startDate = startDate
        location.endDate = endDate
        location.currencyCode = locationCurrency.code
        location.rateToBaseCurrency = exchangeRateLocationToBaseCurrency

        applyBudgets(budgetsByCategory, to: location)
    }

    func delete(_ location: Location) {
        context.delete(location)
    }

    // MARK: - Private Methods

    private func applyBudgets(
        _ budgetsByCategory: [ExpenseCategory: Double],
        to location: Location
    ) {
        let existingBudgets = Dictionary(
            uniqueKeysWithValues: location.budgets.map { ($0.category, $0) }
        )

        for (category, amount) in budgetsByCategory {
            let normalizedAmount = max(0, amount)

            if normalizedAmount > 0 {
                if let budget = existingBudgets[category] {
                    budget.amountInBaseCurrency = normalizedAmount
                } else {
                    let budget = Budget(
                        category: category,
                        amountInBaseCurrency: normalizedAmount,
                        location: location
                    )
                    location.budgets.append(budget)
                }
            } else if let budget = existingBudgets[category] {
                location.budgets.removeAll { $0 === budget }
                context.delete(budget)
            }
        }
    }
}
