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
        localCurrency: Currency,
        rateLocalToBase: Double,
        trip: Trip,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        let location = Location(
            name: name,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: localCurrency.code,
            rateLocalToBase: rateLocalToBase,
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
        localCurrency: Currency,
        rateLocalToBase: Double,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        location.name = name
        location.startDate = startDate
        location.endDate = endDate
        location.localCurrencyCode = localCurrency.code
        location.rateLocalToBase = rateLocalToBase

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
                    budget.baseAmount = amount
                } else {
                    let budget = Budget(
                        category: category,
                        baseAmount: amount,
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
