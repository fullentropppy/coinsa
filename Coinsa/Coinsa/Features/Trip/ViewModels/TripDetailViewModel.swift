//
//  TripDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation
import SwiftUI

struct TripDetailViewModel {
    // MARK: - Stored Properties

    let trip: Trip
    let baseCurrency: Currency

    // MARK: - Computed Properties

    var eventHeaderData: EventSummaryData {
        let plannedAmount = trip.calculatePlannedAmount(asBaseCurrency: true)
        let actualAmount = trip.calculateActualAmount(asBaseCurrency: true)

        return EventSummaryData(
            status: trip.status,
            startDate: trip.startDate,
            endDate: trip.endDate,
            days: trip.durationInDays,
            plannedBaseAmount: plannedAmount,
            actualBaseAmount: actualAmount,
            baseAmountDifference: plannedAmount - actualAmount,
            baseCurrency: baseCurrency,
            plannedLocalAmount: nil,
            actualLocalAmount: nil,
            localAmountDifference: nil,
            localCurrency: nil,
            badgeIcon: Trip.badgeIcon,
            badgeColor: Trip.badgeColor
        )
    }
    
    // MARK: - Initialization

    init(trip: Trip, baseCurrency: Currency) {
        self.trip = trip
        self.baseCurrency = baseCurrency
    }
}
