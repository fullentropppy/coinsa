//
//  TripDetailsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.02.2026.
//

import SwiftUI

struct TripDetailsView: View {
    // MARK: - Stored properties
    
    @State private var viewModel: TripViewModel
    @State private var isShowingEditSheet = false
    @State private var selectedLocation: Location?
    
    let trip: Trip
    
    // MARK: - Initialization
    
    init(trip: Trip) {
        _viewModel = State(initialValue: TripViewModel(trip: trip))
        self.trip = trip
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                tripHeader
                locations
                
                if let selectedLocation {
                    ExpenseListView(location: selectedLocation)
                }
            }
        }
        .navigationTitle(viewModel.name)
        .padding()
        .toolbar {
            Button("common.edit") {
                isShowingEditSheet = true
            }
        }
        .sheet(isPresented: $isShowingEditSheet, onDismiss: {
            viewModel = TripViewModel(trip: trip)
        }) {
            TripEditView(trip: trip)
        }
        .onAppear {
            if selectedLocation == nil {
                selectedLocation = viewModel.locations.first
            }
        }
    }
    
    // MARK: - Subviews
    
    var tripHeader: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.startDate, format: .dateTime.year().month().day())
                Text("–")
                Text(viewModel.endDate, format: .dateTime.year().month().day())
            }
            .foregroundStyle(.secondary)
        }
    }
    
    var locations: some View {
        VStack(alignment: .leading) {
            Text("trip.details.locations.title")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if viewModel.locations.isEmpty {
                        Text("trip.details.locations.empty")
                    } else {
                        ForEach(viewModel.locations) { location in
                            Button {
                                selectedLocation = location
                            } label: {
                                LocationItemView(location: location)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TripDetailsView(trip: PreviewDataFactory.builder().buildFirstTrip())
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TripDetailsView(trip: PreviewDataFactory.builder().buildFirstTrip())
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty locations") {
    TripDetailsView(trip: PreviewDataFactory.builder().withLocations(false).buildFirstTrip())
}

#Preview("Empty expenses") {
    TripDetailsView(trip: PreviewDataFactory.builder().withExpenses(false).buildFirstTrip())
}
