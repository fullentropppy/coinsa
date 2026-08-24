//
//  ExpenseLocationMapView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import SwiftUI

/// Карта с координатами места совершения траты.
struct ExpenseLocationMapView: View {
    // MARK: - Свойства

    @Binding private var coordinate: GeoCoordinate
    private let isEditable: Bool

    // MARK: - Инициализация

    init(coordinate: Binding<GeoCoordinate>, isEditable: Bool) {
        _coordinate = coordinate
        self.isEditable = isEditable
    }

    init(coordinate: GeoCoordinate) {
        self.init(coordinate: .constant(coordinate), isEditable: false)
    }

    // MARK: - Тело View

    var body: some View {
        GeoCoordinateMapView(
            coordinate: $coordinate,
            title: "expense.location",
            isEditable: isEditable,
            accentColor: Expense.accentColor
        )
    }
}

// MARK: - Превью

private extension ExpenseLocationMapView {
    static let previewCoordinate = GeoCoordinate(
        latitude: 41.89021,
        longitude: 12.49223,
        horizontalAccuracy: 12
    )

    static func makePreview(locale: Locale, colorScheme: ColorScheme, isEditable: Bool) -> some View {
        @Previewable @State var coordinate = previewCoordinate

        return List {
            Section("expense.location") {
                ExpenseLocationMapView(coordinate: $coordinate, isEditable: isEditable)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Read. Light - RU") {
    ExpenseLocationMapView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, isEditable: false)
}

#Preview("Edit. Dark - EN") {
    ExpenseLocationMapView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, isEditable: true)
}
