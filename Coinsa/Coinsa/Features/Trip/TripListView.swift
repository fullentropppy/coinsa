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
    
    @State private var tripToEdit: Trip?
    @State private var isShowingItemSheet = false

    // MARK: - Computed properties
    
    private var store: TripStore {
        TripStore(context: context)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(trips) { trip in
                    TripRowView(trip: trip)
                        .onTapGesture { tripToEdit = trip }
                }
            }
            .navigationTitle("trip.list.navigationTitle")
            .sheet(isPresented: $isShowingItemSheet) {
                TripEditView()
            }
            .sheet(item: $tripToEdit) { trip in
                TripEditView(trip: trip)
            }
            .toolbar {
                if !trips.isEmpty {
                    Button("trip.list.addTrip", systemImage: "plus") {
                        isShowingItemSheet = true
                    }
                }
            }
            .overlay {
                if trips.isEmpty {
                    ContentUnavailableView {
                        Label("trip.list.empty.title", systemImage: "suitcase")
                    } description: {
                        Text("trip.list.empty.desctiption")
                    } actions: {
                        Button("trip.list.addTrip") { isShowingItemSheet = true }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    TripListView()
}
