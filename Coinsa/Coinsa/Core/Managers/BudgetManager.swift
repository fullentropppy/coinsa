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
    private(set) var budgetsLocal: [ExpenseCategory: Double]
    
    var totalBaseAmount: Double {
        budgetsBase.values.reduce(0, +)
    }
    
    var totalLocalAmount: Double {
        budgetsLocal.values.reduce(0, +)
    }
    
    // MARK: - Инициализация
    
    init(converter: CurrencyConverter, initialBudgets: [ExpenseCategory: Double] = [:]) {
        let normalizedBudgetsBase = Dictionary(
            uniqueKeysWithValues: ExpenseCategory.allCases.map { category in
                (category, initialBudgets[category] ?? 0)
            }
        )
        let normalizedBudgetsLocal = Dictionary(
            uniqueKeysWithValues: ExpenseCategory.allCases.map { category in
                let baseAmount = normalizedBudgetsBase[category] ?? 0
                return (category, converter.convertToLocal(fromBase: baseAmount))
            }
        )

        self.converter = converter
        self.budgetsBase = normalizedBudgetsBase
        self.budgetsLocal = normalizedBudgetsLocal
    }
    
    // MARK: - Публичные методы
    
    func budgetBase(for category: ExpenseCategory) -> Double {
        budgetsBase[category] ?? 0
    }
    
    func budgetLocal(for category: ExpenseCategory) -> Double {
        budgetsLocal[category] ?? 0
    }
    
    func updateBudget(_ amount: Double, for category: ExpenseCategory, in inputCurrency: InputCurrency) {
        switch inputCurrency {
        case .base:
            budgetsBase[category] = amount
            budgetsLocal[category] = converter.convertToLocal(fromBase: amount)
        case .local:
            budgetsLocal[category] = amount
            budgetsBase[category] = converter.convertToBase(fromLocal: amount)
        }
    }
    
    func updateFromRateChange(inputCurrency: InputCurrency) {
        for category in ExpenseCategory.allCases {
            let currentAmount = amount(for: category, in: inputCurrency)
            updateBudget(currentAmount, for: category, in: inputCurrency)
        }
    }
    
    private func amount(for category: ExpenseCategory, in inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base: budgetBase(for: category)
        case .local: budgetLocal(for: category)
        }
    }
}
