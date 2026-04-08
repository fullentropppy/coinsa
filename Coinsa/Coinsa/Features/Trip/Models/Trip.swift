//
//  Trip.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Trip: DateRangeProviding, EventStatusProviding {
    // MARK: - Stored Properties
    
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    var startDate: Date
    var endDate: Date

    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]
    
    // MARK: - Initialization
    
    init(
        name: String,
        startDate: Date,
        endDate: Date,
        locations: [Location] = []
    ) {
        self.id = UUID()
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locations = locations
    }
}
