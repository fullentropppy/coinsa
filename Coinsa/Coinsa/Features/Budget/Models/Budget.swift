//
//  PlannedBudget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.02.2026.
//

import Foundation
import SwiftData

@Model
class Budget {
    // MARK: - Stored Properties
    
    var category: ExpenseCategory
    var amountBase: Double
    var rateBaseToLocal: Double
    var location: Location
    
    // MARK: - Initialization
    
    init(
        category: ExpenseCategory,
        amountBase: Double,
        rateBaseToLocal: Double,
        location: Location,
    ) {
        self.category = category
        self.amountBase = amountBase
        self.rateBaseToLocal = rateBaseToLocal
        self.location = location
    }
}
