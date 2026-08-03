//
//  EventDaySegmentAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

/// Сводные данные по части суток.
struct EventDaySegmentAnalyticsData {
    let timeOfDay: daySegment
    let expenseCount: Int
    let baseAverageAmount: Double
    let locationAverageAmount: Double?
}
