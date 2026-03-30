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

    var eventHeaderData: EventHeaderData {
        let plannedAmount = trip.calculatePlannedAmount(asBaseCurrency: true)
        let actualAmount = trip.calculateActualAmount(asBaseCurrency: true)

        return EventHeaderData(
            status: trip.status,
            startDate: trip.startDate,
            endDate: trip.endDate,
            durationDays: trip.durationInDays,
            plannedAmountBase: plannedAmount,
            actualAmountBase: actualAmount,
            amountDifferenceBase: plannedAmount - actualAmount,
            baseCurrency: baseCurrency,
            plannedAmountLocal: nil,
            actualAmountLocal: nil,
            amountDifferenceLocal: nil,
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
