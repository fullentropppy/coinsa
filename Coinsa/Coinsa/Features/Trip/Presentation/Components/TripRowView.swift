//
//  TripRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI

/// Строка для отображения поездки в списке.
struct TripRowView: View {
    // MARK: - Свойства
    
    let trip: Trip
    
    // MARK: - Инициализация
    
    /// Создает строку для отображения поездки.
    /// - Parameter trip: Поездка для отображения.
    init(_ trip: Trip) {
        self.trip = trip
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            upperStack
            lowerStack
        }
    }
    
    // MARK: - Компоненты
    
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
            CountLabel.secondarySmall(trip.locationsCount, icon: Location.primaryIcon)
            CountLabel.daysSecondarySmall(trip.totalDays)
        }
    }
}

// MARK: - Превью

private extension TripRowView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false).withExpenses(false)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)

        return List {
            TripRowView(trip)
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
