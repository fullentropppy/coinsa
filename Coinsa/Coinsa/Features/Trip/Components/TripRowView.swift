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

private extension TripRowView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)

        return List {
            TripRowView(trip: trip)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    TripRowView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripRowView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
