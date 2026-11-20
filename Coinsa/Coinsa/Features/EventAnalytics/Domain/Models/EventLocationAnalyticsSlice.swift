//
//  EventLocationAnalyticsSlice.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Траты одной локации в домашней валюте поездки.
struct EventLocationAnalyticsSlice: Identifiable {
    // MARK: - Хранимые свойства

    let location: Location
    let homeAmount: Double
    let expenseCount: Int

    // MARK: - Вычисляемые свойства

    var id: UUID { location.id }

    // MARK: - Публичные методы

    /// Возвращает общую сумму или среднее за календарные дни самой локации.
    /// - Parameter asDailyAverage: Делить сумму на длительность локации с включением обеих дат.
    func amount(asDailyAverage: Bool) -> Double {
        asDailyAverage ? homeAmount / max(Double(location.totalDays), 1) : homeAmount
    }
}
