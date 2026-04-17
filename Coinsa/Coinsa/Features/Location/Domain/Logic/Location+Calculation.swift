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
        let adjustmentMultiplier = 1 + (max(0, exchangeAdjustment) / 100)
        return rateLocalToBase * adjustmentMultiplier
    }
    
    // MARK: - Публичные методы
    
    func calculatePlannedAmount(asBaseCurrency: Bool = true) -> Double {
        budgets.reduce(0) {
            let exchangeRate = asBaseCurrency ? 1 : effectiveRateBaseToLocal
            return $0 + $1.baseAmount * exchangeRate
        }
    }

    func calculateActualAmount(asBaseCurrency: Bool = true) -> Double {
        expenses.reduce(0) {
            let exchangeRate = asBaseCurrency ? 1 : $1.effectiveRateBaseToLocal
            return $0 + $1.baseAmount * exchangeRate
        }
    }
}
