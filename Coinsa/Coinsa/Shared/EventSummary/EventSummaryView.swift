//
//  EventSummaryView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.03.2026.
//

import SwiftUI

struct EventSummaryView: View {
    // MARK: - Stored Properties
    
    let symbolName: String
    let name: String
    let startDate: Date
    let endDate: Date
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: symbolName)
                Text(name)
            }
            .foregroundStyle(.secondary)
            
            DateLabel(
                from: startDate,
                to: endDate,
                style: .tertiary
            )
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Previews

private extension EventSummaryView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        let weekAhead = now.addingTimeInterval(604800)
        
        return EventSummaryView(
            symbolName: "mappin.and.ellipse",
            name: "Токио",
            startDate: now,
            endDate: weekAhead
        )
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventSummaryView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventSummaryView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}

