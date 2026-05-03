//
//  BudgetManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import Observation

/// Менеджер для управления бюджетами по категориям расходов в основной и локальной валютах.
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
    
    /// Создает менеджер бюджетов.
    /// - Parameters:
    ///   - converter: Конвертер валют.
    ///   - initialBudgets: Начальные бюджеты в основной валюте. По умолчанию пустой словарь.
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
    
    /// Возвращает бюджет для категории в основной валюте.
    /// - Parameter category: Категория расхода.
    /// - Returns: Сумма бюджета в основной валюте.
    func budgetBase(for category: ExpenseCategory) -> Double {
        budgetsBase[category] ?? 0
    }
    
    /// Возвращает бюджет для категории в локальной валюте.
    /// - Parameter category: Категория расхода.
    /// - Returns: Сумма бюджета в локальной валюте.
    func budgetLocal(for category: ExpenseCategory) -> Double {
        budgetsLocal[category] ?? 0
    }
    
    /// Обновляет бюджет для категории в указанной валюте.
    /// - Parameters:
    ///   - amount: Новое значение бюджета.
    ///   - category: Категория расхода.
    ///   - inputCurrency: Валюта, в которой задается новое значение.
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
    
    /// Обновляет все бюджеты после изменения курса обмена.
    /// - Parameter inputCurrency: Валюта, значения которой остаются неизменными при пересчете.
    func updateFromRateChange(inputCurrency: InputCurrency) {
        for category in ExpenseCategory.allCases {
            let currentAmount = amount(for: category, in: inputCurrency)
            updateBudget(currentAmount, for: category, in: inputCurrency)
        }
    }
    
    // MARK: - Приватные методы
    
    /// Возвращает бюджет для категории в указанной валюте).
    /// - Parameters:
    ///   - category: Категория расхода.
    ///   - inputCurrency: Валюта.
    /// - Returns: Сумма бюджета.
    private func amount(for category: ExpenseCategory, in inputCurrency: InputCurrency) -> Double {
        switch inputCurrency {
        case .base: budgetBase(for: category)
        case .local: budgetLocal(for: category)
        }
    }
}
