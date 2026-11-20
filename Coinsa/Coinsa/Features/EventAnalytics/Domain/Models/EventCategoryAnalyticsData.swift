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
    let locationBudget: Double?
    let expensesAmountByCategory: [ExpenseAnalyticsSlice]
    let expenses: [Expense]
    let locations: [Location]?
}
