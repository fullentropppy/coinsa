//
//  Trip.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

/// Модель поездки, содержащая информацию о временных рамках и локациях.
@Model
class Trip: DateRangeProviding {
    // MARK: - Свойства
    
    /// Уникальный идентификатор поездки.
    var id: UUID = UUID()
    
    /// Название поездки.
    var name: String = ""
    
    /// Дата начала поездки.
    var startDate: Date = Date()
    
    /// Дата окончания поездки.
    var endDate: Date = Date()
    
    /// Трехбуквенный код ISO 4217 основной валюты в которой записываются все суммы.
    var baseCurrencyCode: String = ""

    /// Список локаций поездки.
    /// При удалении поездки все связанные локации удаляются.
    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]?
    
    /// Дата создания записи.
    var createdAt: Date = Date()
    
    /// Дата последнего обновления записи.
    var updatedAt: Date = Date()
    
    // MARK: - Инициализация
    
    /// Создаёт новую поездку.
    /// - Parameters:
    ///   - id: Уникальный идентификатор.
    ///   - name: Название поездки.
    ///   - startDate: Дата начала.
    ///   - endDate: Дата окончания.
    ///   - baseCurrencyCode: Код основной валюты.
    ///   - locations: Список локаций.
    ///   - createdAt: Дата создания.
    ///   - updatedAt: Дата обновления.
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        baseCurrencyCode: String,
        locations: [Location],
        createdAt: Date,
        updatedAt: Date,
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.baseCurrencyCode = baseCurrencyCode
        self.locations = locations
    }
}
