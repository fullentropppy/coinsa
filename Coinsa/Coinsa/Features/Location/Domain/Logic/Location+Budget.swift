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
        budgets.values.contains { $0 > 0 }
    }
    
    // MARK: - Методы
    
    func budgetAmount(for category: ExpenseCategory) -> Double {
        budgets[category] ?? 0
    }

    func applyBudgets(_ budgetsByCategory: [ExpenseCategory: Double]) {
        budgets = Dictionary(
            uniqueKeysWithValues: ExpenseCategory.allCases.compactMap { category in
                let amount = (budgetsByCategory[category] ?? 0).nonNegative
                guard amount > 0 else {
                    return nil
                }
                return (category, amount)
            }
        )
    }
}
