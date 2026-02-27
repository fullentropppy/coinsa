//
//  TripRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI

struct TripRowView: View {
    // MARK: - Properties
    
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

#Preview {
    let exampleTrip = Trip(
        name: "Japan", startDate: .now , endDate: .now.addingTimeInterval(60 * 60 * 24 * 21), locations: []
    )
    //let exampleLocation1 = Location(name: "Tokyo", trip: exampleTrip)
    //let exampleLocation2 = Location(name: "Osaka", trip: exampleTrip)
    
    TripRowView(trip: exampleTrip)
}
