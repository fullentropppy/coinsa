//
//  TripViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class TripViewModel {
    // MARK: - Properties
    
    var name: String
    var startDate: Date
    var endDate: Date
    var locations: [Location]
    
    private let trip: Trip?
    
    // MARK: - Initialization
    
    init(trip: Trip?) {
        self.trip = trip

        if let trip {
            name = trip.name
            startDate = trip.startDate
            endDate = trip.endDate
            locations = trip.locations
        } else {
            name = ""
            startDate = .now
            endDate = .now
            locations = []
        }
    }
    
    var isEditing: Bool {
        trip != nil
    }

    var title: String {
        String(localized: isEditing ? "trip.editing.navigationTitle.editing" : "trip.editing.navigationTitle.creating")
    }

    func save(using store: TripStore) {
        if let trip {
            store.update(trip, name: name, startDate: startDate, endDate: endDate)
        } else {
            store.add(name: name, startDate: startDate, endDate: endDate)
        }
    }
}
