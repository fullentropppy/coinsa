//
//  Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

import Foundation
import SwiftData

/// Модель бюджета для определенной категории расходов в рамках локации.
@Model
class Budget {
    // MARK: - Свойства

    /// Уникальный идентификатор бюджета.
    var id: UUID = UUID()

    /// Сырое значение категории трат.
    var categoryRaw: String = ""
    
    /// Сумма бюджета в основной валюте поездки.
    var baseAmount: Double = 0
    
    /// Локация, к которой относится бюджет.
    var location: Location? = nil

    /// Дата создания записи.
    var createdAt: Date = Date()
    
    /// Дата последнего обновления записи.
    var updatedAt: Date = Date()
    
    // MARK: - Инициализация

    /// Создает новый бюджет для категории в указанной локации.
    /// - Parameters:
    ///   - id: Уникальный идентификатор.
    ///   - categoryRaw: Сырое значение категории трат.
    ///   - baseAmount: Сумма бюджета в основной валюте.
    ///   - location: Локация, к которой относится бюджет.
    ///   - createdAt: Дата создания.
    ///   - updatedAt: Дата обновления.
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
