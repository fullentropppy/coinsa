//
//  Location+Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.04.2026.
//

import Foundation

extension Location {
    func budgetAmount(for category: ExpenseCategory) -> Double {
        budgets.first(where: { $0.category == category })?.baseAmount ?? 0
    }

    func budgetsByCategory() -> [ExpenseCategory: Double] {
        Dictionary(uniqueKeysWithValues: budgets.map { ($0.category, $0.baseAmount) })
    }

    func applyBudgets(_ budgetsByCategory: [ExpenseCategory: Double]) {
        let normalizedBudgets = ExpenseCategory.allCases.compactMap { category -> Budget? in
            let amount = (budgetsByCategory[category] ?? 0).nonNegative
            guard amount > 0 else {
                return nil
            }
            return Budget(category: category, baseAmount: amount)
        }

        budgets = normalizedBudgets
    }
}
