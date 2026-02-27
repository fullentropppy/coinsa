//
//  Location.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Location {
    // MARK: - Stored properties
    
    var name: String
    var startDate: Date
    var endDate: Date
    var trip: Trip
    
    // MARK: - Initialization
    
    init(name: String, startDate: Date, endDate: Date, trip: Trip) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.trip = trip
    }
}
