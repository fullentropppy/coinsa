//
//  TripRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI

struct TripRowView: View {
    // MARK: - Stored Properties
    
    let trip: Trip
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                EventStatusDotView(status: trip.status)
                EventTitleView(title: trip.name)
            }
            .padding(2)
            
            HStack {
                EventIntervalView(startDate: trip.startDate, endDate: trip.endDate)
                Spacer()
                EventDurationView(days: trip.durationInDays)
                TripLocationCountView(count: trip.locationsCount)
            }
            .padding(2)
        }
    }
}

// MARK: - Previews

private var previewTrip: Trip {
    let builder = PreviewBuilder.builder()
    let data = builder.buildData()
    return builder.getTrip(from: data)
}

#Preview("Light - RU") {
    List {
        TripRowView(trip: previewTrip)
            .environment(\.locale, Locale(identifier: "ru"))
            .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    List {
        TripRowView(trip: previewTrip)
            .environment(\.locale, Locale(identifier: "en"))
            .preferredColorScheme(.dark)
    }
}
