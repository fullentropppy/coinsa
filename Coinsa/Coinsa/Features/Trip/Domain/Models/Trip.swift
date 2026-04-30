//
//  Trip.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Trip: DateRangeProviding {
    // MARK: - Свойства
    
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var name: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var baseCurrencyCode: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]?
    
    // MARK: - Инициализация
    
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
