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
    let baseCurrencyOption: CurrencyOption

    // MARK: - Computed Properties

    var headerData: TripDetailHeaderData {
        let plannedAmount = trip.calculatePlannedAmount(inBase: true)
        let actualAmount = trip.calculateActualAmount(inBase: true)
        
        return TripDetailHeaderData(
            startDate: trip.startDate,
            endDate: trip.endDate,
            durationDays: trip.durationInDays,
            status: trip.status,
            plannedAmount: plannedAmount,
            actualAmount: actualAmount,
            amountDifference: plannedAmount - actualAmount,
            currencyOption: baseCurrencyOption
        )
    }
    
    // MARK: - Initialization

    init(trip: Trip, baseCurrencyOption: CurrencyOption) {
        self.trip = trip
        self.baseCurrencyOption = baseCurrencyOption
    }
}

struct TripDetailHeaderData {
    let startDate: Date
    let endDate: Date
    let durationDays: Int
    let status: EventStatus
    let plannedAmount: Double
    let actualAmount: Double
    let amountDifference: Double
    let currencyOption: CurrencyOption
}
