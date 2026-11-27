//
//  EventCategoryAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import Foundation

/// Структура для хранения данных события для аналитики.
struct EventCategoryAnalyticsData {
    // MARK: - Хранимые свойства

    let title: String
    let dateRangeProvider: DateRangeProviding
    let homeCurrency: Currency
    let locationCurrency: Currency?
    let baseBudget: Double
    let locationConversion: LocationCurrencyConversion?
    let expensesAmountByCategory: [ExpenseAnalyticsSlice]
    let expenses: [Expense]
    let locations: [Location]?

    // MARK: - Вычисляемые свойства

    var locationBudget: Double? {
        locationAmount(forHomeAmount: baseBudget)
    }

    // MARK: - Методы

    /// Переводит домашний итог в валюту локации по единому курсу исходной аналитики.
    /// - Parameter amount: Сумма выбранного набора трат или бюджета в домашней валюте.
    /// - Returns: Эквивалент в валюте локации; для аналитики поездки и общих трат возвращает `nil`.
    func locationAmount(forHomeAmount amount: Double) -> Double? {
        guard locationCurrency != nil else { return nil }
        return locationConversion?.locationAmount(forHomeAmount: amount)
    }
}
