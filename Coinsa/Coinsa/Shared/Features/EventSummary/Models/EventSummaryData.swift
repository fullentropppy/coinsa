//
//  EventSummaryData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct EventSummaryData {
    // MARK: - Свойства
    
    let badgeProvider: TypeBadgeProviding.Type
    let statusProvider: EventStatusProviding
    let plannedBaseAmount: Double
    let actualBaseAmount: Double
    let baseCurrency: Currency
    let plannedLocalAmount: Double?
    let actualLocalAmount: Double?
    let localCurrency: Currency?
    
    // MARK: - Инициализация
    
    init(
        badgeProvider: TypeBadgeProviding.Type,
        statusProvider: EventStatusProviding,
        plannedBaseAmount: Double,
        actualBaseAmount: Double,
        baseCurrency: Currency,
        plannedLocalAmount: Double? = nil,
        actualLocalAmount: Double? = nil,
        localCurrency: Currency? = nil
    ) {
        self.badgeProvider = badgeProvider
        self.statusProvider = statusProvider
        self.plannedBaseAmount = plannedBaseAmount
        self.actualBaseAmount = actualBaseAmount
        self.baseCurrency = baseCurrency
        self.plannedLocalAmount = plannedLocalAmount
        self.actualLocalAmount = actualLocalAmount
        self.localCurrency = localCurrency
    }
}
