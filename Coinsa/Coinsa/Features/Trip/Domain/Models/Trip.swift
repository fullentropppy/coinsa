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
    
    @Attribute(.unique)
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    var name: String
    var startDate: Date
    var endDate: Date
    var baseCurrency: Currency

    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]
    
    // MARK: - Инициализация
    
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        baseCurrency: Currency,
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
        self.baseCurrency = baseCurrency
        self.locations = locations
    }
}
