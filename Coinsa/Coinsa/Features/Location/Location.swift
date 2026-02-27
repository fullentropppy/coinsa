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
    // MARK: - Properties
    
    var name: String
    var trip: Trip
    
    // MARK: - Initialization
    
    init(name: String, trip: Trip) {
        self.name = name
        self.trip = trip
    }
}
