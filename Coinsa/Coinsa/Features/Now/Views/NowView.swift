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

    @Query(sort: \Location.startDate) private var location: [Location]


    // MARK: - Computed Properties

    private var currentLocation: Location? {
        let today = Date.now
        return location.first { $0.startDate <= today && $0.endDate >= today }
    }

    private var upcomingLocation: Location? {
        let today = Date.now
        return location.first { $0.startDate > today }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            if let currentLocation {
                LocationDetailView(location: currentLocation)
            } else {
//                UpcomingTripView(trip: upcomingLocation)
//                    .navigationTitle("now.navigationTitle")
//                    .navigationBarTitleDisplayMode(.large)
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
