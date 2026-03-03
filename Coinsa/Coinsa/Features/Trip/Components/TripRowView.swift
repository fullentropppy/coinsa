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
            Text(trip.name).font(.title2).fontWeight(.semibold)
            
            HStack {
                TripStatusView(status: trip.status)
                Spacer()
                HStack(spacing: 2) {
                    Text(trip.startDate..<trip.endDate, format: Date.tripIntervalFormat)
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(String(trip.locationsCount))
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews

fileprivate var previewTrip: Trip {
    let trips = PreviewDataBuilder.builder().buildData()
    return trips.first!
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
