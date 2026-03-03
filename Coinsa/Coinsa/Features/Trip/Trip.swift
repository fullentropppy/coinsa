//
//  Trip.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Trip {
    // MARK: - Stored Properties
    
    var name: String
    var startDate: Date
    var endDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]
    
    // MARK: - Computed Properties
    
    var locationsCount: Int {
        locations.count
    }
    
    var status: EventStatus {
        let now = Date.now
        
        if now < startDate {
            return .upcoming
        } else if now >= startDate && now < endDate {
            return .ongoing
        } else {
            return .completed
        }
    }
    
    // MARK: - Initialization
    
    init(name: String, startDate: Date, endDate: Date, locations: [Location] = []) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locations = locations
    }
}
