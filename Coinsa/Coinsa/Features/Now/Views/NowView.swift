//
//  NowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct NowView: View {
    // MARK: - Stored Properties

    @Query(sort: \Trip.startDate) private var trips: [Trip]


    // MARK: - Computed Properties

    private var currentTrip: Trip? {
        let today = Date.now
        return trips.first { $0.startDate <= today && $0.endDate >= today }
    }

    private var upcomingTrip: Trip? {
        let today = Date.now
        return trips.first { $0.startDate > today }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            if let currentTrip {
                TripDetailView(trip: currentTrip)
            } else {
                UpcomingTripView(trip: upcomingTrip)
                    .navigationTitle("now.navigationTitle")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    let container = PreviewBuilder.builder().buildContainer()
    return NowView()
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}
