//
//  BudgetManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Observation

@MainActor
@Observable
final class BudgetManager {
    // MARK: - Свойства
    
    private let converter: CurrencyConverter
    private(set) var budgetsBase: [ExpenseCategory: Double]
    
    var totalBaseAmount: Double {
        budgetsBase.values.reduce(0, +)
    }
    
    // MARK: - Инициализация
    
    init(converter: CurrencyConverter, initialBudgets: [ExpenseCategory: Double] = [:]) {
        self.converter = converter
        self.budgetsBase = initialBudgets
    }
    
    // MARK: - Публичные методы
    
    func budgetBase(for category: ExpenseCategory) -> Double {
        budgetsBase[category] ?? 0
    }
    
    func budgetLocal(for category: ExpenseCategory) -> Double {
        let baseAmount = budgetBase(for: category)
        return converter.convertToLocal(fromBase: baseAmount).rounded()
    }
    
    func updateBudget(_ amount: Double, for category: ExpenseCategory, in inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base: budgetsBase[category] = amount
        case .local: budgetsBase[category] = converter.convertToBase(fromLocal: amount)
        }
    }
}
