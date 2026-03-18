//
//  TripDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation

struct TripDetailViewModel {
    // MARK: - Stored Properties

    let trip: Trip
    let baseCurrency: Currency

    // MARK: - Computed Properties

    var headerData: TripDetailHeaderData {
        let plannedAmount = trip.calculatePlannedAmount(inBase: true)
        let actualAmount = trip.calculateActualAmount(inBase: true)
        
        return TripDetailHeaderData(
            status: trip.status,
            startDate: trip.startDate,
            endDate: trip.endDate,
            durationDays: trip.durationInDays,
            plannedAmount: plannedAmount,
            actualAmount: actualAmount,
            amountDifference: plannedAmount - actualAmount,
            currency: baseCurrency
        )
    }
    
    // MARK: - Initialization

    init(trip: Trip, baseCurrency: Currency) {
        self.trip = trip
        self.baseCurrency = baseCurrency
    }
}

// MARK: - Supporting Types

struct TripDetailHeaderData {
    let status: EventStatus
    let startDate: Date
    let endDate: Date
    let durationDays: Int
    let plannedAmount: Double
    let actualAmount: Double
    let amountDifference: Double
    let currency: Currency
}
