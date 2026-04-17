//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

extension Expense {
    // MARK: - Публичные свойства
    
    var localAmount: Double {
        baseAmount * effectiveRateBaseToLocal
    }
    
    var effectiveRateLocalToBase: Double {
        adjustedRateLocalToBase
    }
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase).rounded(to: 4) : 0
    }
    
    var effectiveRateBaseToLocal: Double {
        adjustedRateLocalToBase > 0 ? (1 / adjustedRateLocalToBase) : 0
    }
    
    // MARK: - Приватные свойства
    
    private var adjustedRateLocalToBase: Double {
        let adjustmentMultiplier = 1 + (max(0, exchangeAdjustment) / 100)
        return (rateLocalToBase * adjustmentMultiplier).rounded(to: 4)
    }
}
