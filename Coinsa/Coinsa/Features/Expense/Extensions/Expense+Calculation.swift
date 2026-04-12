//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Expense {
    // MARK: - Computed Properties
    
    var localAmount: Double {
        baseAmount * effectiveRateBaseToLocal
    }
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    var effectiveRateLocalToBase: Double {
        adjustedRateLocalToBase
    }
    
    var effectiveRateBaseToLocal: Double {
        adjustedRateLocalToBase > 0 ? (1 / adjustedRateLocalToBase) : 0
    }
    
    // MARK: - Private Methods
    
    private var adjustedRateLocalToBase: Double {
        let adjustmentMultiplier = 1 + (max(0, exchangeAdjustmentPercentage) / 100)
        return rateLocalToBase * adjustmentMultiplier
    }
}
