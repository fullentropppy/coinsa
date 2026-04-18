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
    
    @Attribute(.unique)
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    var category: ExpenseCategory
    var baseAmount: Double
    var location: Location
    
    // MARK: - Инициализация
    
    init(category: ExpenseCategory, baseAmount: Double, location: Location) {
        let now = Date()
        
        self.id = UUID()
        self.createdAt = now
        self.updatedAt = now
        
        self.category = category
        self.baseAmount = baseAmount
        self.location = location
    }
}
