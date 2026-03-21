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
        currency: Currency,
        rateToBaseCurrency: Double,
        trip: Trip,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        let location = Location(
            name: name,
            startDate: startDate,
            endDate: endDate,
            currencyCode: currency.code,
            rateToBaseCurrency: rateToBaseCurrency,
            trip: trip,
            budgets: [],
            expenses: []
        )

        applyBudgets(budgetsByCategory, to: location)
        context.insert(location)
        try? context.save()
    }

    func update(
        _ location: Location,
        name: String,
        startDate: Date,
        endDate: Date,
        currency: Currency,
        rateToBaseCurrency: Double,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        location.name = name
        location.startDate = startDate
        location.endDate = endDate
        location.currencyCode = currency.code
        location.rateToBaseCurrency = rateToBaseCurrency

        applyBudgets(budgetsByCategory, to: location)
        try? context.save()
    }

    func delete(_ location: Location) {
        context.delete(location)
        try? context.save()
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
            if amount > 0 {
                if let budget = existingBudgets[category] {
                    budget.amountInBaseCurrency = amount
                } else {
                    let budget = Budget(
                        category: category,
                        amountInBaseCurrency: amount,
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
