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
    // MARK: - Свойства

    let context: ModelContext

    // MARK: - Операции с хранилищем
    
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        localCurrency: Currency,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        trip: Trip,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        let location = Location(
            name: name.trimmed,
            startDate: startDate,
            endDate: endDate,
            localCurrencyCode: localCurrency.code,
            rateLocalToBase: rateLocalToBase.nonNegative,
            exchangeAdjustment: exchangeAdjustment.nonNegative,
            trip: trip
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
        exchangeAdjustment: Double,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        location.name = name.trimmed
        location.startDate = startDate
        location.endDate = endDate
        location.localCurrencyCode = localCurrency.code
        location.rateLocalToBase = rateLocalToBase.nonNegative
        location.exchangeAdjustment = exchangeAdjustment.nonNegative
        location.updatedAt = Date()
        
        applyBudgets(budgetsByCategory, to: location)
        try? context.save()
    }

    func delete(_ location: Location) {
        context.delete(location)
        try? context.save()
    }

    // MARK: - Приватные методы

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
                    budget.baseAmount = amount.nonNegative
                    budget.updatedAt = Date()
                } else {
                    let budget = Budget(
                        category: category,
                        baseAmount: amount.nonNegative,
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
