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
    let baseCurrencyCode: String

    // MARK: - Computed Properties

    var headerData: TripDetailHeaderData {
        TripDetailHeaderData(
            startDate: trip.startDate,
            endDate: trip.endDate,
            durationDays: trip.durationInDays,
            status: trip.status,
            plannedAmount: plannedAmount,
            actualAmount: actualAmount,
            amountDifference: plannedAmount - actualAmount,
            currencyCode: baseCurrencyCode
        )
    }
    
    // MARK: - Initialization

    init(trip: Trip, currencyCode: String = Locale.current.currency?.identifier ?? "USD") {
        self.trip = trip
        self.baseCurrencyCode = currencyCode
    }

    // MARK: - Private Methods

    private var plannedAmount: Double {
        trip.locations
            .flatMap(\.budgets)
            .reduce(0) { $0 + $1.amountInBaseCurrency }
    }

    private var actualAmount: Double {
        trip.locations
            .flatMap(\.expenses)
            .reduce(0) { $0 + $1.amountInLocationCurrency * $1.exchangeRateLocationToBaseCurrency }
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
    let currencyCode: String
}
