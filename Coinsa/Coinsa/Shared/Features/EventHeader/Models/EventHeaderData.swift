//
//  EventHeaderData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct EventHeaderData {
    let status: EventStatus
    let startDate: Date
    let endDate: Date
    let durationDays: Int
    let plannedAmountBase: Double
    let actualAmountBase: Double
    let amountDifferenceBase: Double
    let baseCurrency: Currency
    let plannedAmountLocal: Double?
    let actualAmountLocal: Double?
    let amountDifferenceLocal: Double?
    let localCurrency: Currency?
    let badgeIcon: String
    let badgeColor: Color
}
