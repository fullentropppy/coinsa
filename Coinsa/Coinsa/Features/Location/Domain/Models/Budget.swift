//
//  Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.02.2026.
//

import Foundation
import SwiftData

@Model
class Budget {
    // MARK: - Свойства
    
    var category: ExpenseCategory
    var baseAmount: Double
    var location: Location
    
    // MARK: - Инициализация
    
    init(category: ExpenseCategory, baseAmount: Double, location: Location) {
        self.category = category
        self.baseAmount = baseAmount
        self.location = location
    }
}
