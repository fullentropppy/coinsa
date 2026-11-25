//
//  Trip+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Trip {
    // MARK: - Плановая сумма
    
    /// Рассчитывает полный бюджет поездки в домашней валюте.
    /// - Returns: Бюджеты локаций и общих трат без смешения локальных валют.
    func calculateBudgetAmount() -> Double {
        generalExpensesBudget + (locations ?? []).reduce(0) {
            $0 + $1.calculateBudgetAmount(in: .home)
        }
    }

    // MARK: - Фактическая сумма
    
    /// Рассчитывает все траты поездки в домашней валюте, включая общие траты.
    /// - Parameter targetRange: Включенный диапазон гражданских дат или nil для всей истории.
    /// - Returns: Фактическая сумма с однократным учетом каждой траты.
    func calculateExpensesAmount(withinDateRange targetRange: ClosedRange<Date>? = nil) -> Double {
        allExpenses.reduce(0) { result, expense in
            guard targetRange.map({ $0.contains(expense.civilDateTime.storedDate) }) != false else { return result }
            return result + expense.amount(in: .home)
        }
    }

    /// Рассчитывает суммы всех трат поездки по категориям в домашней валюте.
    /// - Parameter targetRange: Включенный диапазон гражданских дат или nil для всей истории.
    /// - Returns: Словарь категорий и сумм, согласованный с полным итогом поездки.
    func calculateExpensesAmountByCategory(withinDateRange targetRange: ClosedRange<Date>? = nil) -> [ExpenseCategory: Double] {
        allExpenses.reduce(into: [:]) { result, expense in
            guard targetRange.map({ $0.contains(expense.civilDateTime.storedDate) }) != false else { return }
            result[expense.category, default: 0] += expense.amount(in: .home)
        }
    }
}
