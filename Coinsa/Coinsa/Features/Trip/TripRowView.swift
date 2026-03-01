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
                .font(.title)
            HStack {
                Text(trip.startDate, format: .dateTime.year().month().day())
                Text("–")
                Text(trip.endDate, format: .dateTime.year().month().day())
                Text("–")
                Text(String(trip.locations.count))
            }
        }
    }
}

// MARK: - Previews


#Preview("Light - RU") {
    TripRowView(trip: PreviewDataFactory.builder().buildFirstTrip())
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TripRowView(trip: PreviewDataFactory.builder().buildFirstTrip())
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty locations") {
    TripRowView(trip: PreviewDataFactory.builder().withLocations(false).buildFirstTrip())
}
