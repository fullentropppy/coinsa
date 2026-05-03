//
//  Location+Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.04.2026.
//

import Foundation

extension Location {
    // MARK: - Свойства
    
    /// Признак наличия ненулевых бюджетов в локации.
    var hasBudget: Bool {
        budgets?.contains { $0.baseAmount > 0 } ?? false
    }
    
    /// Бюджеты по категориям в основной валюте.
    var budgetsByCategory: [ExpenseCategory: Double] {
        budgets?.reduce(into: [:]) { result, budget in
            result[budget.category] = budget.baseAmount
        } ?? [:]
    }
    
    // MARK: - Методы
    
    /// Возвращает бюджет для указанной категории.
    /// - Parameter category: Категория расхода.
    /// - Returns: Сумма бюджета в основной валюте.
    func budgetAmount(for category: ExpenseCategory) -> Double {
        budgets?.first(where: { $0.category == category })?.baseAmount ?? 0
    }
    
    /// Применяет бюджеты к локации (создает, обновляет или удаляет).
    /// - Parameter budgetsByCategory: Новые бюджеты по категориям.
    func applyBudgets(_ budgetsByCategory: [ExpenseCategory: Double]) {
        if budgets == nil {
            budgets = []
        }
        
        var normalizedBudgets: [ExpenseCategory: Double] = [:]
        
        for category in ExpenseCategory.allCases {
            let amount = (budgetsByCategory[category] ?? 0).nonNegative
            if amount > 0 {
                normalizedBudgets[category] = amount
            }
        }
        
        budgets?.removeAll { budget in
            normalizedBudgets[budget.category] == nil
        }
        
        let now = Date()
        
        for (category, amount) in normalizedBudgets {
            if let existingBudget = budgets?.first(where: { $0.category == category }) {
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
                budgets?.append(budget)
            }
        }
    }
}
