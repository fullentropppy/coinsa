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
    let currencyCode: String

    // MARK: - Computed Properties

    var dateIntervalText: String {
        "10-10"
        //String(DateInterval(start: trip.startDate, end: trip.endDate)
    }

    var plannedAmountText: String {
        formattedCurrency(plannedAmount)
    }

    var actualAmountText: String {
        formattedCurrency(actualAmount)
    }

    // MARK: - Initialization

    init(trip: Trip, currencyCode: String = Locale.current.currency?.identifier ?? "USD") {
        self.trip = trip
        self.currencyCode = currencyCode
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

    private func formattedCurrency(_ amount: Double) -> String {
        amount.formatted(.currency(code: currencyCode))
    }
}
