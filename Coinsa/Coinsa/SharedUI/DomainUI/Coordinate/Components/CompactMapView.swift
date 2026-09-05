//
//  CompactMapView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import MapKit
import SwiftUI

/// Карта с отображением и редактированием географической координаты.
struct CompactMapView: View {
    // MARK: - Состояние

    @Binding private var coordinate: Coordinate
    @State private var cameraPosition: MapCameraPosition

    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let isEditable: Bool
    private let height: CGFloat

    // MARK: - Инициализация
    
    /// Создает редактируемую карту с привязкой к координате.
    /// - Parameters:
    ///   - coordinate: Привязка к объекту координат.
    ///   - title: Заголовок маркера на карте.
    ///   - isEditable: Доступно ли редактирование координаты.
    ///   - height: Высота карты. По умолчанию `200`.
    init(
        _ coordinate: Binding<Coordinate>,
        title: LocalizedStringResource,
        isEditable: Bool,
        height: CGFloat = 200
    ) {
        _coordinate = coordinate
        _cameraPosition = State(initialValue: Self.cameraPosition(for: coordinate.wrappedValue))
        self.title = title
        self.isEditable = isEditable
        self.height = height
    }

    /// Создает карту только для чтения с фиксированной координатой.
    /// - Parameters:
    ///   - coordinate: Объект координат для отображения.
    ///   - title: Заголовок маркера на карте.
    ///   - height: Высота карты. По умолчанию `200`.
    init(
        _ coordinate: Coordinate,
        title: LocalizedStringResource,
        height: CGFloat = 200
    ) {
        self.init(
            .constant(coordinate),
            title: title,
            isEditable: false,
            height: height
        )
    }

    // MARK: - Тело View

    var body: some View {
        mapContent
            .onChange(of: coordinate) { _, newValue in
                cameraPosition = Self.cameraPosition(for: newValue)
            }
    }

    // MARK: - Компоненты

    private var mapContent: some View {
        VStack(alignment: .center, spacing: 10) {
            Map(position: $cameraPosition, interactionModes: []) {
                Marker(String(localized: title), coordinate: coordinate.coreLocationCoordinate)
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            CoordinateBadge(coordinate, withBackground: false)
        }
    }

    // MARK: - Инфраструктура
    
    private static func cameraPosition(for coordinate: Coordinate) -> MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: coordinate.coreLocationCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

// MARK: - Превью

private extension CompactMapView {
    static let previewCoordinate = Coordinate(
        latitude: 35.65949,
        longitude: 139.70057,
        horizontalAccuracy: 12
    )

    static func makePreview(locale: Locale, colorScheme: ColorScheme, isEditable: Bool) -> some View {
        @Previewable @State var coordinate = previewCoordinate

        return List {
            CompactMapView($coordinate, title: .expensePlaceOfExpense, isEditable: isEditable)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Read. Light - RU") {
    CompactMapView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, isEditable: false)
}

#Preview("Edit. Dark - EN") {
    CompactMapView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, isEditable: true)
}
