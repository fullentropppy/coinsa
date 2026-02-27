//
//  TripRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI

struct TripRowView: View {
    // MARK: - Stored properties
    
    let trip: Trip
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(trip.name)
            HStack {
                Text(trip.startDate, format: .dateTime.year().month().day())
                Text(trip.endDate, format: .dateTime.year().month().day())
                Text(String(trip.locations.count))
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let exampleTrip = Trip(
        name: "Japan",
        startDate: .now,
        endDate: .now.addingTimeInterval(60 * 60 * 24 * 21)
    )
    TripRowView(trip: exampleTrip)
}
