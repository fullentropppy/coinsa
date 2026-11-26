//
//  EventLocationAnalyticsSlice.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Доля трат одной локации в домашней валюте поездки.
struct EventLocationAnalyticsSlice: Identifiable {
    // MARK: - Свойства

    let location: Location
    let homeAmount: Double
    let expenseCount: Int

    var id: UUID { location.id }
    var totalDays: Int { location.totalDays }

    // MARK: - Методы

    /// Возвращает сумму трат или среднее за календарные дни локации.
    /// - Parameter asDailyAverage: Делить сумму на длительность локации с включением обеих дат.
    func amount(asDailyAverage: Bool) -> Double {
        asDailyAverage ? homeAmount / max(Double(totalDays), 1) : homeAmount
    }
}
