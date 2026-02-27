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
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(viewModel.startDate, format: .dateTime.year().month().day())
                        Text("–")
                        Text(viewModel.endDate, format: .dateTime.year().month().day())
                    }
                    .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("trip.details.locations.title")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if viewModel.locations.isEmpty {
                                Text("trip.details.locations.empty")
                            } else {
                                ForEach(viewModel.locations) { location in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(location.name)
                                        HStack(spacing: 6) {
                                            Text(location.startDate, format: .dateTime.year().month().day())
                                            Text("–")
                                            Text(location.endDate, format: .dateTime.year().month().day())
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                    .padding(10)
                                    .frame(width: 200, alignment: .leading)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.name)
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
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TripDetailsView(trip: PreviewData.firstTrip)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TripDetailsView(trip: PreviewData.firstTrip)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
