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
    @State private var deletionHandler = DeletionHandler<Location>(
        singleMessageKey: "location.deletionConfirmation.message.single",
        multipleMessageKey: "location.deletionConfirmation.message.multiple"
    )
    
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
            .onDelete(perform: requestDelete)
        }
        .toolbar {
            toolbarContent
        }
        .alert("location.list.deletionConfirmation.title", isPresented: $deletionHandler.isShowingDeleteConfirmation) {
            Button("location.list.deletionConfirmation.delete", role: .destructive) {
                confirmDelete()
            }
            Button("common.cancel", role: .cancel) {
                cancelDelete()
            }
        } message: {
            Text(deletionHandler.confirmationMessage)
        }
        .overlay {
            if locations.isEmpty {
                LocationEmptyStateView(onAddLocation: onAddLocation)
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
    }

    // MARK: - Actions

    private var store: LocationStore {
        LocationStore(context: context)
    }

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.requestDelete(items: offsets.map { locations[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { store.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

private struct previewData {
    let container: ModelContainer
    let trip: Trip
    
    init(withLocations: Bool) {
        let builder = PreviewBuilder.builder().withLocations(withLocations)
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
