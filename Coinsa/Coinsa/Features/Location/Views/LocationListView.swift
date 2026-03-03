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
    
    @Environment(\.modelContext) private var context
    @Query private var locations: [Location]
    
    private let trip: Trip
    
    // MARK: - Initialization
    
    init(trip: Trip) {
        self.trip = trip
        let tripID = trip.persistentModelID
        
        _locations = Query(
            filter: #Predicate<Location> { $0.trip.persistentModelID == tripID },
            sort: \.startDate
        )
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(locations) { location in
                    NavigationLink {
                        
                    } label: {
                        LocationRowView(location: location)
                    }
                }
            }
            .navigationTitle("location.list.navigationTitle")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .overlay {
                if locations.isEmpty {
                    LocationEmptyStateView(onAddLocation: {})
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !locations.isEmpty {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("trip.list.addTrip", systemImage: "plus") {
            
            }
        }
    }
}

// MARK: - Previews

fileprivate struct previewData {
    let withLocations: Bool
    let container: ModelContainer
    let trip: Trip
    
    private let builder = PreviewDataBuilder.builder()
    
    init(withLocations: Bool) {
        self.withLocations = withLocations
        self.container = builder.withLocations(withLocations).buildContainer()
        self.trip = builder.fetchTrip(from: container)
    }
}

#Preview("Light - RU") {
    let data = previewData(withLocations: true)
    LocationListView(trip: data.trip)
        .modelContainer(data.container)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    let data = previewData(withLocations: true)
    LocationListView(trip: data.trip)
        .modelContainer(data.container)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty list") {
    let data = previewData(withLocations: false)
    LocationListView(trip: data.trip)
        .modelContainer(data.container)
}
