//
//  EventToolbarTitleView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.03.2026.
//

import SwiftUI

struct EventToolbarTitleView: View {
    // MARK: - Stored Properties
    
    let title: String
    let eventName: String
    let startDate: Date
    let endDate: Date
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text(title).font(.headline)
            HStack {
                Text(eventName).font(.footnote).foregroundStyle(.secondary)
                DateLabel(
                    from: startDate,
                    to: endDate,
                    style: .tertiary
                )
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 20)
        .glassEffect(.regular, in: Capsule())
    }
}

// MARK: - Previews

private extension EventToolbarTitleView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        let weekAhead = now.addingTimeInterval(604800)
        
        return NavigationStack {
            Form {
                EmptyView()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EventToolbarTitleView(
                        title: "Заголовок",
                        eventName: "Событие",
                        startDate: now,
                        endDate: weekAhead)
                }
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventToolbarTitleView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventToolbarTitleView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}

