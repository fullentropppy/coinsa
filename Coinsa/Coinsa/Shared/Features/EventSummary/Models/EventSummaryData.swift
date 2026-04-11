//
//  EventSummaryData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct EventSummaryData {
    // MARK: - Stored Properties
    
    let badgeIcon: String
    let badgeColor: Color
    let status: EventStatus
    let startDate: Date
    let endDate: Date
    let plannedBaseAmount: Double
    let actualBaseAmount: Double
    let baseCurrency: Currency
    let plannedLocalAmount: Double?
    let actualLocalAmount: Double?
    let localCurrency: Currency?
    
    // MARK: - Initialization
    
    init(
        badgeIcon: String,
        badgeColor: Color,
        status: EventStatus,
        startDate: Date,
        endDate: Date,
        plannedBaseAmount: Double,
        actualBaseAmount: Double,
        baseCurrency: Currency,
        plannedLocalAmount: Double? = nil,
        actualLocalAmount: Double? = nil,
        localCurrency: Currency? = nil
    ) {
        self.badgeIcon = badgeIcon
        self.badgeColor = badgeColor
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.plannedBaseAmount = plannedBaseAmount
        self.actualBaseAmount = actualBaseAmount
        self.baseCurrency = baseCurrency
        self.plannedLocalAmount = plannedLocalAmount
        self.actualLocalAmount = actualLocalAmount
        self.localCurrency = localCurrency
    }
}
