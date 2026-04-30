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

    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var categoryRaw: String = ""
    var baseAmount: Double = 0
    var location: Location? = nil

    // MARK: - Инициализация

    init(
        id: UUID,
        categoryRaw: String,
        baseAmount: Double,
        location: Location,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        self.categoryRaw = categoryRaw
        self.baseAmount = baseAmount
        self.location = location
    }
}
