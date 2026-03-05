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
            dateRange: dateIntervalText,
            durationText: durationText,
            status: trip.status,
            plannedAmount: plannedAmountText,
            actualAmount: actualAmountText,
            amountDifference: amountDifferenceText,
            amountDifferenceValue: plannedAmount - actualAmount
        )
    }
    
    var dateIntervalText: String {
        (trip.startDate..<trip.endDate).formatted(Date.tripIntervalFormat)
    }

    var plannedAmountText: String {
        formattedCurrency(plannedAmount)
    }

    var actualAmountText: String {
        formattedCurrency(actualAmount)
    }

    var amountDifferenceText: String {
        formattedCurrency(plannedAmount - actualAmount)
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

    private var durationText: String {
        String(
            format: NSLocalizedString("trip.detail.summary.days", comment: ""),
            trip.durationInDays
        )
    }

    private func formattedCurrency(_ amount: Double) -> String {
        amount.formatted(.currency(code: baseCurrencyCode))
    }
}

struct TripDetailHeaderData {
    let dateRange: String
    let durationText: String
    let status: EventStatus
    let plannedAmount: String
    let actualAmount: String
    let amountDifference: String
    let amountDifferenceValue: Double
}
