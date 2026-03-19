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
                EventStatusImage(location.status)
                TitleText(location.name)
            }
            .padding(2)
            
            HStack {
                DateLabel(from: location.startDate, to: location.endDate, style: .secondary)
                Spacer()
                DurationLabel(days: location.durationInDays)
            }
            .padding(2)
        }
    }
}

// MARK: - Previews

private extension LocationRowView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder
            .builder()
            .withBudgets(false)
            .withExpenses(false)
        
        let data = builder.buildData()
        let location = builder.getLocation(from: data)

        return List {
            LocationRowView(location: location)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    LocationRowView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    LocationRowView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
