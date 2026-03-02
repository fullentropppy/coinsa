//
//  TripListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    // MARK: - Stored properties
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Trip.startDate) var trips: [Trip]
    
    @State private var isShowingEdtitingSheet = false
    @State private var tripToShow: Trip?
    @State private var deletionHandler = TripDeletionHandler()

    // MARK: - Computed properties
    
    private var store: TripStore {
        TripStore(context: context)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(trips) { trip in
                    NavigationLink {
                        
                    } label: {
                        TripRowView(trip: trip)
                    }
                }
                .onDelete(perform: requestDelete)
            }
            .navigationTitle("trip.list.navigationTitle")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingEdtitingSheet) {
                TripEditView(trip: nil)
            }
            .navigationDestination(item: $tripToShow) { trip in
                
            }
            .alert("trip.list.deletionConfirmation.title", isPresented: $deletionHandler.isShowingDeleteConfirmation) {
                Button("trip.list.deletionConfirmation.delete", role: .destructive) {
                    confirmDelete()
                }
                Button("common.cancel", role: .cancel) {
                    cancelDelete()
                }
            } message: {
                Text(deletionHandler.confirmationMessage)
            }
            .toolbar {
                toolbarContent
            }
            .overlay {
                if trips.isEmpty {
                    TripEmptyStateView { isShowingEdtitingSheet = true }
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !trips.isEmpty {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("trip.list.addTrip", systemImage: "plus") {
                isShowingEdtitingSheet = true
            }
        }
    }
    
    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.requestDelete(trips: offsets.map { trips[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete(using: store)
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TripListView()
        .modelContainer(PreviewDataFactory.builder().buildContainer())
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TripListView()
        .modelContainer(PreviewDataFactory.builder().buildContainer())
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty list") {
    TripListView()
        .modelContainer(PreviewDataFactory.builder().withTrips(false).buildContainer())
}
