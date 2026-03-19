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
                EventStatusImage(trip.status)
                TitleText(trip.name)
            }
            .padding(2)
            
            HStack {
                DateLabel(from: trip.startDate, to: trip.endDate, style: .secondary)
                Spacer()
                DurationLabel(days: trip.durationInDays)
                TripLocationCountLabel(count: trip.locationsCount)
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
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TripRowView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripRowView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
