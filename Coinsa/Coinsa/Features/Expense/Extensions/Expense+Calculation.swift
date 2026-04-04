//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Expense {
    var localAmount: Double {
        baseAmount * rateBaseToLocal
    }
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
}
