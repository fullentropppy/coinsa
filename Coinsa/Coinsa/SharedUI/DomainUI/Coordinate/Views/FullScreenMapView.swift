//
//  FullScreenMapView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import MapKit
import SwiftUI

/// Полноэкранная карта для просмотра или выбора географической координаты.
struct FullScreenMapView: View {
    // MARK: - Окружение

    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние

    @Binding private var coordinate: Coordinate
    @State private var draftCoordinate: Coordinate
    @State private var cameraPosition: MapCameraPosition

    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let isEditable: Bool

    // MARK: - Инициализация

    /// Создает полноэкранную карту для редактирования координаты.
    /// - Parameters:
    ///   - coordinate: Привязка к объекту координат.
    ///   - title: Заголовок навигационной панели.
    init(coordinate: Binding<Coordinate>, title: LocalizedStringResource) {
        let initialCoordinate = coordinate.wrappedValue

        _coordinate = coordinate
        _draftCoordinate = State(initialValue: initialCoordinate)
        _cameraPosition = State(initialValue: Self.cameraPosition(for: initialCoordinate))
        self.title = title
        self.isEditable = true
    }

    /// Создает полноэкранную карту только для чтения.
    /// - Parameters:
    ///   - coordinate: Объект координат для отображения.
    ///   - title: Заголовок навигационной панели.
    init(coordinate: Coordinate, title: LocalizedStringResource) {
        _coordinate = .constant(coordinate)
        _draftCoordinate = State(initialValue: coordinate)
        _cameraPosition = State(initialValue: Self.cameraPosition(for: coordinate))
        self.title = title
        self.isEditable = false
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            mapContent
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .ignoresSafeArea()
                .safeAreaInset(edge: .bottom) {
                    CoordinateBadge(draftCoordinate)
                }
        }
    }

    // MARK: - Компоненты

    private var mapContent: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
                Marker(String(localized: title), coordinate: draftCoordinate.coreLocationCoordinate)
        }
        .onMapCameraChange(frequency: .continuous) { context in
            if isEditable {
                draftCoordinate = Coordinate(context.camera.centerCoordinate, horizontalAccuracy: nil)
            }
        }
    }

    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ToolbarButton.close {
                dismiss()
            }
        }
        
        if isEditable {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ToolbarButton.ok {
                    coordinate = draftCoordinate
                    dismiss()
                }
            }
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

private extension FullScreenMapView {
    static let previewCoordinate = Coordinate(
        latitude: 35.65949,
        longitude: 139.70057,
        horizontalAccuracy: 12
    )

    static func makePreview(locale: Locale, colorScheme: ColorScheme, isEditable: Bool) -> some View {
        @Previewable @State var coordinate = previewCoordinate

        return Group {
            if isEditable {
                FullScreenMapView(coordinate: $coordinate, title: .expensePlaceOfExpense)
            } else {
                FullScreenMapView(coordinate: coordinate, title: .expensePlaceOfExpense)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Read. Light - RU") {
    FullScreenMapView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, isEditable: false)
}

#Preview("Edit. Dark - EN") {
    FullScreenMapView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, isEditable: true)
}
