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
    // MARK: - Константы

    private enum Layout {
        /// Высота компактной карты, если вызывающий экран не задал другую.
        static let defaultHeight: CGFloat = 200
        /// Радиус скругления компактной карты.
        static let cornerRadius: CGFloat = 12
    }

    // MARK: - Состояние

    @Binding private var coordinate: Coordinate
    @State private var cameraPosition: MapCameraPosition

    // MARK: - Свойства

    private let markerTitle: LocalizedStringResource
    private let height: CGFloat

    // MARK: - Инициализация
    
    /// Создает редактируемую карту с привязкой к координате.
    /// - Parameters:
    ///   - coordinate: Привязка к объекту координат.
    ///   - markerTitle: Заголовок маркера на карте.
    ///   - height: Высота карты. По умолчанию `200`.
    init(
        _ coordinate: Binding<Coordinate>,
        markerTitle: LocalizedStringResource,
        height: CGFloat = Layout.defaultHeight
    ) {
        _coordinate = coordinate
        _cameraPosition = State(initialValue: Self.cameraPosition(for: coordinate.wrappedValue))
        self.markerTitle = markerTitle
        self.height = height
    }

    /// Создает карту только для чтения с фиксированной координатой.
    /// - Parameters:
    ///   - coordinate: Объект координат для отображения.
    ///   - markerTitle: Заголовок маркера на карте.
    ///   - height: Высота карты. По умолчанию `200`.
    init(
        _ coordinate: Coordinate,
        markerTitle: LocalizedStringResource,
        height: CGFloat = Layout.defaultHeight
    ) {
        self.init(
            .constant(coordinate),
            markerTitle: markerTitle,
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
        Map(position: $cameraPosition, interactionModes: []) {
            Marker(String(localized: markerTitle), coordinate: coordinate.coreLocationCoordinate)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
    }

    // MARK: - Инфраструктура
    
    private static func cameraPosition(for coordinate: Coordinate) -> MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: coordinate.coreLocationCoordinate,
                span: MKCoordinateSpan(latitudeDelta: MapLayout.detailSpanDelta, longitudeDelta: MapLayout.detailSpanDelta)
            )
        )
    }
}

// MARK: - Превью

#Preview {
    @Previewable @State var coordinate = PreviewGenerator.makeExampleCoordinate()
    
    List {
        CompactMapView($coordinate, markerTitle: .expensePlaceOfExpense)
    }
}
