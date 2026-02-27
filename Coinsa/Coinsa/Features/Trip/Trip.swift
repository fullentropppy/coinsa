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
    // MARK: - Stored properties
    
    var name: String
    var startDate: Date
    var endDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]
    
    // MARK: - Initialization
    
    init(name: String, startDate: Date, endDate: Date, locations: [Location] = []) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.locations = locations
    }
}
