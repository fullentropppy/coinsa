//
//  Trip+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Trip {
    // MARK: - Плановая сумма
    
    func calculatePlannedAmount(asBaseCurrency: Bool = true, asDailyAverage: Bool = false) -> Double {
        locations.reduce(0) {
            $0 + $1.calculatePlannedAmount(asBaseCurrency: asBaseCurrency, asDailyAverage: asDailyAverage)
        }
    }
    
    func calculatePlannedAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        locations.reduce(into: [:]) { result, location in
            let locationValues = location.calculatePlannedAmountByCategory(
                asBaseCurrency: asBaseCurrency,
                withinDateRange: withinDateRange
            )

            for (category, amount) in locationValues {
                result[category, default: 0] += amount
            }
        }
    }
    
    // MARK: - Фактическая сумма
    
    func calculateActualAmount(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> Double {
        locations.reduce(0) {
            $0 + $1.calculateActualAmount(asBaseCurrency: asBaseCurrency, withinDateRange: withinDateRange)
        }
    }

    func calculateActualAmountByCategory(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> [ExpenseCategory: Double] {
        locations.reduce(into: [:]) { result, location in
            let locationValues = location.calculateActualAmountByCategory(
                asBaseCurrency: asBaseCurrency,
                withinDateRange: withinDateRange
            )

            for (category, amount) in locationValues {
                result[category, default: 0] += amount
            }
        }
    }
}
