//
//  PreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@MainActor
struct PreviewData {
    // MARK: - Stored properties
    
    private static let dayInSec = 60.0 * 60.0 * 24.0
    
    // MARK: - Computed properties
    
    static let container: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Trip.self, Location.self, configurations: configuration)
        let context = container.mainContext

        let japanTrip = Trip(
            name: "Japan",
            startDate: .now,
            endDate: .now.addingTimeInterval(dayInSec * 14)
        )

        let tokyo = Location(
            name: "Tokyo",
            startDate: .now,
            endDate: .now.addingTimeInterval(dayInSec * 10),
            trip: japanTrip
        )
        let osaka = Location(
            name: "Osaka",
            startDate: .now.addingTimeInterval(dayInSec * 10),
            endDate: .now.addingTimeInterval(dayInSec * 14),
            trip: japanTrip
        )
        japanTrip.locations = [tokyo, osaka]

        let southKoreaTrip = Trip(
            name: "South Korea",
            startDate: .now.addingTimeInterval(dayInSec * 14),
            endDate: .now.addingTimeInterval(dayInSec * 21),
        )
        let seoul = Location(
            name: "Seoul",
            startDate: southKoreaTrip.startDate,
            endDate: southKoreaTrip.startDate.addingTimeInterval(dayInSec * 7),
            trip: southKoreaTrip
        )
        southKoreaTrip.locations = [seoul]

        context.insert(japanTrip)
        context.insert(southKoreaTrip)

        return container
    }()
    
    static var trips: [Trip] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate)])
        return (try? context.fetch(descriptor)) ?? []
    }

    static var firstTrip: Trip {
        trips.first ?? Trip(name: "Example", startDate: .now, endDate: .now)
    }
}
