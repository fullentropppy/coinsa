//
//  EventSummaryData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct EventSummaryData {
    let status: EventStatus
    let startDate: Date
    let endDate: Date
    let days: Int
    let plannedBaseAmount: Double
    let actualBaseAmount: Double
    let baseAmountDifference: Double
    let baseCurrency: Currency
    let plannedLocalAmount: Double?
    let actualLocalAmount: Double?
    let localAmountDifference: Double?
    let localCurrency: Currency?
    let badgeIcon: String
    let badgeColor: Color
}
