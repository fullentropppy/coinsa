//
//  EventAnalyticsExpensesSummary.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.11.2026.
//

/// Итоги выбранного набора трат и средние за день исходного события для шапки аналитики.
struct EventAnalyticsExpensesSummary: Equatable {
    // MARK: - Хранимые свойства

    let homeAmount: Double
    let homeCurrency: Currency
    let locationAmount: Double?
    let locationCurrency: Currency?
    let dailyHomeAmount: Double
    let dailyLocationAmount: Double?
    let totalDays: Int
}
