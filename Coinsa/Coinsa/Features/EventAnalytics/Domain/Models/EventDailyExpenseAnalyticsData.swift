//
//  EventDailyExpenseAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.08.2026.
//

/// Данные дневной суммы трат для графика аналитики события.
struct EventDailyExpenseAnalyticsData: Identifiable {
    // MARK: - Хранимые свойства

    let date: PlainDate
    let expenseCount: Int
    let homeAmount: Double
    let locationAmount: Double?
    
    // MARK: - Вычисляемые свойства

    var id: PlainDate { date }
}
