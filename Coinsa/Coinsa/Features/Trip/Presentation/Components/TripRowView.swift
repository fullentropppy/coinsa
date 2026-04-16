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
        VStack(alignment: .leading, spacing: 10) {
            upperStack
            lowerStack
        }
    }
    
    // MARK: - Components
    
    private var upperStack: some View {
        HStack(spacing: 4) {
            trip.status.makeDot()
            Text(trip.name).fontWeight(.semibold)
        }
    }
    
    private var lowerStack: some View {
        HStack(spacing: 10) {
            DateLabel.secondarySmall(from: trip.startDate, to: trip.endDate)
            Spacer()
            CountLabel.secondarySmall(trip.locations.count, icon: Location.primaryIcon)
            CountLabel.daysSecondarySmall(trip.durationInDays)
        }
    }
}

// MARK: - Previews

private extension TripRowView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false).withExpenses(false)
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
    TripRowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripRowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
