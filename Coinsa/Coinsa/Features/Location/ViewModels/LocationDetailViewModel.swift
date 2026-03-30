//
//  LocationDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import Foundation
import SwiftUI

struct LocationDetailViewModel {
    // MARK: - Stored Properties

    let location: Location
    let baseCurrency: Currency
    let localCurrency: Currency

    // MARK: - Computed Properties

    var eventHeaderData: EventHeaderData {
        let plannedAmountBase = location.calculatePlannedAmount(asBaseCurrency: true)
        let plannedAmountLocal = location.calculatePlannedAmount(asBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(asBaseCurrency: true)
        let actualAmountLocal = location.calculateActualAmount(asBaseCurrency: false)
        let hasLocalAmounts = localCurrency != baseCurrency && location.rateLocalToBase > 0

        return EventHeaderData(
            status: location.status,
            startDate: location.startDate,
            endDate: location.endDate,
            durationDays: location.durationInDays,
            plannedAmountBase: plannedAmountBase,
            actualAmountBase: actualAmountBase,
            amountDifferenceBase: plannedAmountBase - actualAmountBase,
            baseCurrency: baseCurrency,
            plannedAmountLocal: hasLocalAmounts ? plannedAmountLocal : nil,
            actualAmountLocal: hasLocalAmounts ? actualAmountLocal : nil,
            amountDifferenceLocal: hasLocalAmounts ? plannedAmountLocal - actualAmountLocal : nil,
            localCurrency: hasLocalAmounts ? localCurrency : nil,
            badgeIcon: Location.badgeIcon,
            badgeColor: Location.badgeColor
        )
    }

    // MARK: - Initialization

    init(location: Location, baseCurrency: Currency) {
        self.location = location
        self.baseCurrency = baseCurrency
        self.localCurrency = Currency.from(location.currencyCodeLocal)
    }
}
