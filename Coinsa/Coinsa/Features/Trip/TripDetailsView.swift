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
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.startDate, format: .dateTime.year().month().day())
                        Text("–")
                        Text(viewModel.endDate, format: .dateTime.year().month().day())
                    }
                    .foregroundStyle(.secondary)
                }

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
                                        VStack(alignment: .leading) {
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
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                
                if let selectedLocation {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(selectedLocation.expenses.sorted(by: { $0.date > $1.date })) { expense in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(expense.date, format: .dateTime.year().month().day())
                                    Text(expense.category.localized)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(
                                    expense.amountInLocationCurrency,
                                    format: .currency(code: selectedLocation.locationCurrencyCode)
                                )
                            }
                            .padding(10)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
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
        .onAppear {
            if selectedLocation == nil {
                selectedLocation = viewModel.locations.first
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
