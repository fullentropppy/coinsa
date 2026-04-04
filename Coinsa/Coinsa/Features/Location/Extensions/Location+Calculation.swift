//
//  Location+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Location {
    // MARK: - Computed Properties
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    // MARK: - Public Methods
    
    func calculatePlannedAmount(asBaseCurrency: Bool = true) -> Double {
        budgets.reduce(0) {
            let exchangeRate = asBaseCurrency ? 1 : rateBaseToLocal
            return $0 + $1.baseAmount * exchangeRate
        }
    }

    func calculateActualAmount(asBaseCurrency: Bool = true) -> Double {
        expenses.reduce(0) {
            let exchangeRate = asBaseCurrency ? 1 : $1.rateBaseToLocal
            return $0 + $1.baseAmount * exchangeRate
        }
    }
}
