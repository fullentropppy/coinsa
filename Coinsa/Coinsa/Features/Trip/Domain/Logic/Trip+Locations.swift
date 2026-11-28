//
//  Trip+Locations.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Trip {
    // MARK: - Свойства

    /// Признак наличия локаций в поездке.
    var hasLocations: Bool {
        locations?.isEmpty == false
    }
    
    /// Количество локаций в поездке.
    var locationsCount: Int {
        locations?.count ?? 0
    }

    var locationExpenses: [Expense] {
        allExpenses.filter { $0.location != nil }
    }

    // MARK: - Расчеты

    /// Суммирует бюджеты локаций в домашней валюте без бюджета общих трат.
    /// - Returns: Бюджет всех локаций без промежуточного округления.
    func calculateLocationsBudgetAmount() -> Double {
        (locations ?? []).reduce(0) { $0 + $1.calculateBudgetAmount(in: .home) }
    }

    /// Суммирует траты локаций этой поездки в домашней валюте.
    /// - Returns: Домашняя сумма без общих трат и повторной корректировки курса.
    func calculateLocationsExpensesAmount() -> Double {
        locationExpenses.reduce(0) { $0 + $1.amount(in: .home) }
    }

    /// Группирует домашние суммы трат локаций по категориям.
    /// - Returns: Категории, согласованные со сводкой локаций и их аналитикой.
    func calculateLocationsExpensesAmountByCategory() -> [ExpenseCategory: Double] {
        locationExpenses.reduce(into: [:]) { result, expense in
            result[expense.category, default: 0] += expense.amount(in: .home)
        }
    }
}
