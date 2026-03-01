//
//  LocationItemView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI

struct LocationItemView: View {
    // MARK: - Stored properties
    
    let location: Location
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(location.name)
            HStack(spacing: 6) {
                Text(location.startDate, format: .dateTime.year().month().day())
                Text("–")
                Text(location.endDate, format: .dateTime.year().month().day())
            }
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(width: 200, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    LocationItemView(location: PreviewDataFactory.Builder().buildFirstLocation())
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    LocationItemView(location: PreviewDataFactory.Builder().buildFirstLocation())
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
