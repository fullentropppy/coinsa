//
//  LocationDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import Foundation

struct LocationDetailViewModel {
    // MARK: - Stored Properties

    let location: Location
    let baseCurrency: Currency
    let localCurrency: Currency

    // MARK: - Computed Properties

    var headerData: LocationDetailHeaderData {
        let plannedAmountBase = location.calculatePlannedAmount(inBaseCurrency: true)
        let plannedAmountLocal = location.calculatePlannedAmount(inBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(inBaseCurrency: true)
        let actualAmountLocal = location.calculateActualAmount(inBaseCurrency: false)

        return LocationDetailHeaderData(
            status: location.status,
            startDate: location.startDate,
            endDate: location.endDate,
            durationDays: location.durationInDays,
            plannedAmountLocal: plannedAmountLocal,
            plannedAmountBase: plannedAmountBase,
            actualAmountLocal: actualAmountLocal,
            actualAmountBase: actualAmountBase,
            amountDifferenceLocal: plannedAmountLocal - actualAmountLocal,
            amountDifferenceBase: plannedAmountBase - actualAmountBase,
            localCurrency: localCurrency,
            baseCurrency: baseCurrency
        )
    }

    // MARK: - Initialization

    init(location: Location, baseCurrency: Currency) {
        self.location = location
        self.baseCurrency = baseCurrency
        self.localCurrency = Currency.from(code: location.currencyCode)
    }
}

struct LocationDetailHeaderData {
    let status: EventStatus
    let startDate: Date
    let endDate: Date
    let durationDays: Int
    let plannedAmountLocal: Double
    let plannedAmountBase: Double
    let actualAmountLocal: Double
    let actualAmountBase: Double
    let amountDifferenceLocal: Double
    let amountDifferenceBase: Double
    let localCurrency: Currency
    let baseCurrency: Currency
}
