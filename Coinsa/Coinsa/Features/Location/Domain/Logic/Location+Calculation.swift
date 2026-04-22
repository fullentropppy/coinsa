//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Публичные свойства
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    var effectiveRateLocalToBase: Double {
        adjustedRateLocalToBase
    }
    
    var effectiveRateBaseToLocal: Double {
        adjustedRateLocalToBase > 0 ? (1 / adjustedRateLocalToBase) : 0
    }
    
    // MARK: - Приватные свойства
    
    private var adjustedRateLocalToBase: Double {
        let adjustmentMultiplier = 1 + (exchangeAdjustment / 100)
        return rateLocalToBase * adjustmentMultiplier
    }
    
    // MARK: - Публичные методы
    
    func calculatePlannedAmountForToday(asBaseCurrency: Bool = true) -> Double {
        let plannedAmount = calculatePlannedAmount(asBaseCurrency: asBaseCurrency, asDailyAverage: false)
        
        if totalDays == 1 {
            return plannedAmount
        }
        
        let endOfYesterday = Date().yesterday.endOfDay
        let startRange = min(startDate, endOfYesterday)
        let endRange = max(startRange, endOfYesterday)
        
        let actualAmount = calculateActualAmount(
            asBaseCurrency: asBaseCurrency,
            withinDateRange: startRange...endRange
        )
        
        return remainingDays == 0 ? 0 : (plannedAmount - actualAmount) / Double(remainingDays)
    }
    
    func calculatePlannedAmount(asBaseCurrency: Bool = true, asDailyAverage: Bool = false) -> Double {
        let plannedAmount = budgets.reduce(0) {
            let exchangeRate = asBaseCurrency ? 1 : effectiveRateBaseToLocal
            return $0 + $1.baseAmount * exchangeRate
        }
        return asDailyAverage ? plannedAmount / Double(totalDays).rounded() : plannedAmount
    }

    func calculateActualAmount(
        asBaseCurrency: Bool = true,
        withinDateRange: ClosedRange<Date>? = nil
    ) -> Double {
        expenses.reduce(0) { result, expense in
            if let withinDateRange, !withinDateRange.contains(expense.date) {
                return result
            }
            
            let exchangeRate = asBaseCurrency ? 1 : expense.effectiveRateBaseToLocal
            return result + expense.baseAmount * exchangeRate
        }
    }
}
