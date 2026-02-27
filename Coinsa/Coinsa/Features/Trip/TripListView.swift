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
            }
            .navigationTitle("trip.list.navigationTitle")
            .sheet(isPresented: $isShowingEdtitingSheet) {
                TripEditView(trip: nil)
            }
            .navigationDestination(item: $tripToShow) { trip in
                TripDetailsView(trip: trip)
            }
            .toolbar {
                if !trips.isEmpty {
                    Button("trip.list.addTrip", systemImage: "plus") {
                        isShowingEdtitingSheet = true
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
                        Button("trip.list.addTrip") { isShowingEdtitingSheet = true }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TripListView()
        .modelContainer(PreviewData.container)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}
#Preview("Dark - EN") {
    TripListView()
        .modelContainer(PreviewData.container)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
