//
//  Trip+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Trip {
    func calculatePlannedAmount(asBaseCurrency: Bool = true, asDailyAverage: Bool = false) -> Double {
        locations.reduce(0) {
            $0 + $1.calculatePlannedAmount(asBaseCurrency: asBaseCurrency, asDailyAverage: asDailyAverage)
        }
    }
    
    func calculateActualAmount(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> Double {
        locations.reduce(0) {
            $0 + $1.calculateActualAmount(asBaseCurrency: asBaseCurrency, withinDateRange: withinDateRange)
        }
    }
}
