//
//  LocationListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

struct LocationListView: View {
    @Environment(\.modelContext) private var context

    let trip: Trip
    @Query private var locations: [Location]

    init(trip: Trip) {
        self.trip = trip
        let tripID = trip.persistentModelID
        _locations = Query(
            filter: #Predicate<Location> { $0.trip.persistentModelID == tripID },
            sort: \.startDate
        )
    }

    var body: some View {
        List {
            ForEach(locations) { location in
                
            }
        }
        .toolbar {
        
        }
    }
}
