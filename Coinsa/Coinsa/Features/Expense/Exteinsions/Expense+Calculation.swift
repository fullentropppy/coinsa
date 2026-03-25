//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

import Foundation

extension Expense {
    var amountLocal: Double {
        amountBase * rateBaseToLocal
    }
}
