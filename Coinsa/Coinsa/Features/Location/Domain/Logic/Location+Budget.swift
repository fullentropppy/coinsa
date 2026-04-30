//
//  Location+Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.04.2026.
//

import Foundation

extension Location {
    // MARK: - Свойства

    var hasBudget: Bool {
        budgets?.contains { $0.baseAmount > 0 } ?? false
    }

    var budgetsByCategory: [ExpenseCategory: Double] {
        budgets?.reduce(into: [:]) { result, budget in
            result[budget.category] = budget.baseAmount
        } ?? [:]
    }

    // MARK: - Методы

    func budgetAmount(for category: ExpenseCategory) -> Double {
        budgets?.first(where: { $0.category == category })?.baseAmount ?? 0
    }

    func applyBudgets(_ budgetsByCategory: [ExpenseCategory: Double]) {
        guard var budgets else { return }
        
        var normalizedBudgets: [ExpenseCategory: Double] = [:]

        for category in ExpenseCategory.allCases {
            let amount = (budgetsByCategory[category] ?? 0).nonNegative
            if amount > 0 {
                normalizedBudgets[category] = amount
            }
        }

        budgets.removeAll { budget in
            normalizedBudgets[budget.category] == nil
        }

        let now = Date()
        
        for (category, amount) in normalizedBudgets {
            if let existingBudget = budgets.first(where: { $0.category == category }) {
                existingBudget.baseAmount = amount
                existingBudget.updatedAt = now
            } else {
                let budget = Budget(
                    id: UUID(),
                    categoryRaw: category.rawValue,
                    baseAmount: amount,
                    location: self,
                    createdAt: now,
                    updatedAt: now
                )
                budgets.append(budget)
            }
        }
    }
}
