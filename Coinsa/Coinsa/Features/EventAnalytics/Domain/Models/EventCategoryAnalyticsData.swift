//
//  EventCategoryAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import Foundation

/// Структура для хранения данные события для аналитики.
struct EventCategoryAnalyticsData {
    let dateRangeProvider: DateRangeProviding
    let baseCurrency: Currency
    let locationCurrency: Currency?
    let baseBudget: Double
    let locationBudget: Double?
    let expensesAmountByCategory: [ExpenseAnalyticsSlice]
    let expenses: [Expense]
}
