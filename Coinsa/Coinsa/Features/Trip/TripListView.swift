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
    @State private var isShowingDeleteConfirmation = false
    @State private var tripsPendingDeletion: [Trip] = []

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
                        TripDetailsView(trip: trip)
                    } label: {
                        TripRowView(trip: trip)
                    }
                }
                .onDelete(perform: requestDelete)
            }
            .navigationTitle("trip.list.navigationTitle")
            .sheet(isPresented: $isShowingEdtitingSheet) {
                TripEditView(trip: nil)
            }
            .navigationDestination(item: $tripToShow) { trip in
                TripDetailsView(trip: trip)
            }
            .alert("trip.list.deletionConfirmation.title", isPresented: $isShowingDeleteConfirmation) {
                Button("trip.list.deletionConfirmation.delete", role: .destructive) {
                    confirmDelete()
                }
                Button("common.cancel", role: .cancel) {
                    cancelDelete()
                }
            } message: {
                Text(deleteConfirmationMessage)
            }
            .toolbar {
                toolbarContent
            }
            .overlay {
                if trips.isEmpty {
                    emptyStateView
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
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("trip.list.empty.title", systemImage: "suitcase")
        } description: {
            Text("trip.list.empty.desctiption")
        } actions: {
            Button("trip.list.addTrip") { isShowingEdtitingSheet = true }
        }
    }

    private var deleteConfirmationMessage: LocalizedStringKey {
        tripsPendingDeletion.count == 1
        ? "trip.list.deletionConfirmation.message.single"
        : "trip.list.deletionConfirmation.message.multiple"
    }

    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        tripsPendingDeletion = offsets.map { trips[$0] }
        isShowingDeleteConfirmation = true
    }

    private func confirmDelete() {
        tripsPendingDeletion.forEach { store.delete($0) }
        tripsPendingDeletion.removeAll()
    }

    private func cancelDelete() {
        tripsPendingDeletion.removeAll()
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
