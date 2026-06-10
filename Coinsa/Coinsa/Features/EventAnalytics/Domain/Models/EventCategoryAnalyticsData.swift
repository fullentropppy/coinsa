//
//  EventCategoryAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import Foundation

/// Структура для хранения данные события для аналитики.
struct EventCategoryAnalyticsData {
    let dateRange: ClosedRange<Date>
    let baseCurrency: Currency
    let locationCurrency: Currency?
    let baseBudget: Double
    let localBudget: Double?
    let actualAmountByCategory: [ExpenseAnalyticsSlice]
}
