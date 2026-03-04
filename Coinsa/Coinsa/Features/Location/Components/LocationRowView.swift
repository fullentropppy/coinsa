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
            Text(location.name).font(.title2).fontWeight(.semibold)
            
            HStack {
                EventStatusView(status: location.status)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(location.startDate..<location.endDate, format: Date.tripIntervalFormat)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Previews

fileprivate var previewLocation: Location {
    let builder = PreviewDataBuilder.builder()
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
