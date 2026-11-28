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
}
