//
//  LocationRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

struct LocationRowView: View {
    // MARK: - Stored Properties
    
    let location: Location
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                EventStatusImage(status: location.status)
                EventTitleText(title: location.name)
            }
            .padding(2)
            
            HStack {
                EventIntervalText(startDate: location.startDate, endDate: location.endDate)
                Spacer()
                EventDurationLabel(days: location.durationInDays)
            }
            .padding(2)
        }
    }
}

// MARK: - Previews

private var previewLocation: Location {
    let builder = PreviewBuilder.builder()
    let data = builder.buildData()
    return builder.getLocation(from: data)
}

#Preview("Light - RU") {
    List {
        LocationRowView(location: previewLocation)
            .environment(\.locale, Locale(identifier: "ru"))
            .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    List {
        LocationRowView(location: previewLocation)
            .environment(\.locale, Locale(identifier: "en"))
            .preferredColorScheme(.dark)
    }
}
