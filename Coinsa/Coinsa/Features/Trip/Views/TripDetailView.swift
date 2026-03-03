//
//  TripDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    // MARK: - Stored Properties
    
    let trip: Trip
    @State private var isShowingTripEdit = false
    @State private var isShowingLocationAdd = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            LocationListView(
                trip: trip,
                onAddLocation: { isShowingLocationAdd = true }
            )
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

        }
        .sheet(isPresented: $isShowingTripEdit) {
            
        }
        .sheet(isPresented: $isShowingLocationAdd) {
            
        }
    }
}

// MARK: - Previews

fileprivate struct previewData {
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
    NavigationStack {
        TripDetailView(trip: data.trip)
            .modelContainer(data.container)
            .environment(\.locale, Locale(identifier: "ru"))
            .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    let data = previewData(withLocations: true)
    NavigationStack {
        TripDetailView(trip: data.trip)
            .modelContainer(data.container)
            .environment(\.locale, Locale(identifier: "en"))
            .preferredColorScheme(.dark)
    }
}

#Preview("Empty list") {
    let data = previewData(withLocations: false)
    NavigationStack {
        TripDetailView(trip: data.trip)
            .modelContainer(data.container)
    }
}
