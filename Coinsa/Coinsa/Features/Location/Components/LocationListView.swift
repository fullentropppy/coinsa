//
//  LocationListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

struct LocationListView: View {
    // MARK: - Stored Properties
    
    @Query private var locations: [Location]
    
    private let trip: Trip
    private let onAddLocation: () -> Void
    
    // MARK: - Initialization
    
    init(trip: Trip, onAddLocation: @escaping () -> Void) {
        self.trip = trip
        self.onAddLocation = onAddLocation
        let tripID = trip.persistentModelID
        
        _locations = Query(
            filter: #Predicate<Location> { $0.trip.persistentModelID == tripID },
            sort: \.startDate
        )
    }

    var body: some View {
        List {
            ForEach(locations) { location in
                NavigationLink {
                    
                } label: {
                    LocationRowView(location: location)
                }
            }
        }
        .overlay {
            if locations.isEmpty {
                LocationEmptyStateView(onAddLocation: onAddLocation)
            }
        }
    }
}

// MARK: - Previews

private struct previewData {
    let container: ModelContainer
    let trip: Trip
    
    init(withLocations: Bool) {
        let builder = PreviewDataBuilder.builder().withLocations(withLocations)
        self.container = builder.buildContainer()
        self.trip = builder.fetchTrip(from: container)
    }
}

#Preview("Light - RU") {
    let data = previewData(withLocations: true)
    LocationListView(trip: data.trip, onAddLocation: {})
        .modelContainer(data.container)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    let data = previewData(withLocations: true)
    LocationListView(trip: data.trip, onAddLocation: {})
        .modelContainer(data.container)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty list") {
    let data = previewData(withLocations: false)
    LocationListView(trip: data.trip, onAddLocation: {})
        .modelContainer(data.container)
}
