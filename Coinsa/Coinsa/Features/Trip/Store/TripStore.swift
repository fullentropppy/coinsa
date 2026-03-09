//
//  TripStore.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@MainActor
struct TripStore {
    // MARK: - Stored Properties
    
    let context: ModelContext

    // MARK: - Public Methods
    
    func add(name: String, startDate: Date, endDate: Date) {
        let trip = Trip(
            name: name,
            startDate: startDate,
            endDate: endDate,
            locations: []
        )
        context.insert(trip)
    }

    func update(_ trip: Trip, name: String, startDate: Date, endDate: Date) {
        trip.name = name
        trip.startDate = startDate
        trip.endDate = endDate
        trip.locations = []
    }

    func delete(_ trip: Trip) {
        context.delete(trip)
    }
}
