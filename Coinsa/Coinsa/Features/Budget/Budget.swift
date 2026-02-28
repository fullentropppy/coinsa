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
    // MARK: - Stored properties
    
    var category: ExpenseCategory
    var amountInBaseCurrency: Double
    var location: Location
    
    // MARK: - Initialization
    
    init(category: ExpenseCategory, amountInBaseCurrency: Double, location: Location) {
        self.category = category
        self.amountInBaseCurrency = amountInBaseCurrency
        self.location = location
    }
}
