//
//  EventDailyExpenseAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.08.2026.
//

/// Данные дневной суммы трат для графика аналитики события.
struct EventDailyExpenseAnalyticsData: Identifiable {
    let date: PlainDate
    let baseAmount: Double
    let locationAmount: Double?
    
    var id: PlainDate { date }
}
