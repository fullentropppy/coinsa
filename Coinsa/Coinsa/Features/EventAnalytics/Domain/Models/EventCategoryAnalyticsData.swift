//
//  EventCategoryAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import Foundation

struct EventCategoryAnalyticsData {
    // MARK: - Свойства

    let dateRange: ClosedRange<Date>
    let baseCurrency: Currency
    let localCurrency: Currency?
    let budgetByCategory: [CategoryAnalyticsSlice]
    let expenseByCategory: [CategoryAnalyticsSlice]
}

struct CategoryAnalyticsSlice: Identifiable {
    // MARK: - Свойства

    let category: ExpenseCategory
    let baseAmount: Double
    let localAmount: Double?

    var id: String { category.id }
}
