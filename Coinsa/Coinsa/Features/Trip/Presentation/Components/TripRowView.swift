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
        VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
            upperStack
            lowerStack
        }
    }
    
    // MARK: - Компоненты
    
    private var upperStack: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            trip.status.makeDot()
            Text(trip.name).fontWeight(.semibold)
        }
    }
    
    private var lowerStack: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            DateLabel.secondarySmall(from: trip.startPlainDate, to: trip.endPlainDate)
            Spacer()
            CountLabel.secondarySmall(trip.locationsCount, icon: Location.primaryIcon)
            DotDivider.secondarySmall()
            CountLabel.daysSecondarySmall(trip.totalDays)
        }
    }
}

// MARK: - Превью

#Preview {
    List {
        TripRowView(PreviewGenerator.makeExampleTrip(includeLocations: true))
    }
}
