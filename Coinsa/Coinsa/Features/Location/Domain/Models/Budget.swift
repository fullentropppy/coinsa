//
//  Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
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

    init(
        id: UUID,
        category: ExpenseCategory,
        baseAmount: Double,
        location: Location,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        self.category = category
        self.baseAmount = baseAmount
        self.location = location
    }
}
