//
//  CoordinateMapFullScreenView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import MapKit
import SwiftUI

/// Полноэкранная карта для просмотра или выбора географической координаты.
struct CoordinateMapFullScreenView: View {
    // MARK: - Окружение

    @Environment(\.dismiss) private var dismiss

    // MARK: - Состояние

    @Binding private var coordinate: GeoCoordinate
    @State private var draftCoordinate: GeoCoordinate
    @State private var cameraPosition: MapCameraPosition

    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let isEditable: Bool
    private let accentColor: Color

    // MARK: - Инициализация

    init(
        coordinate: Binding<GeoCoordinate>,
        title: LocalizedStringResource,
        accentColor: Color = .accentColor
    ) {
        let initialCoordinate = coordinate.wrappedValue

        _coordinate = coordinate
        _draftCoordinate = State(initialValue: initialCoordinate)
        _cameraPosition = State(initialValue: Self.cameraPosition(for: initialCoordinate))
        self.title = title
        self.isEditable = true
        self.accentColor = accentColor
    }

    init(
        coordinate: GeoCoordinate,
        title: LocalizedStringResource,
        accentColor: Color = .accentColor
    ) {
        _coordinate = .constant(coordinate)
        _draftCoordinate = State(initialValue: coordinate)
        _cameraPosition = State(initialValue: Self.cameraPosition(for: coordinate))
        self.title = title
        self.isEditable = false
        self.accentColor = accentColor
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            ZStack {
                mapContent
                    .ignoresSafeArea()

                if isEditable {
                    centerMarker
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .safeAreaInset(edge: .bottom) {
                coordinateOverlay
            }
        }
    }

    // MARK: - Компоненты

    private var mapContent: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            if !isEditable {
                Marker(String(localized: title), coordinate: draftCoordinate.locationCoordinate)
            }
        }
        .onMapCameraChange(frequency: .continuous) { context in
            guard isEditable else { return }

            draftCoordinate = GeoCoordinate(context.camera.centerCoordinate, horizontalAccuracy: nil)
        }
    }

    private var centerMarker: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: 38, weight: .semibold))
            .foregroundStyle(.white, accentColor)
            .shadow(radius: 5, y: 3)
            .offset(y: -18)
            .allowsHitTesting(false)
    }

    private var coordinateOverlay: some View {
        HStack(spacing: 8) {
            Image(systemName: "location")
                .imageScale(.small)

            Text(draftCoordinate.formattedDescription)
                .font(.footnote.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: Capsule())
        .padding(.bottom, 8)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if isEditable {
                Button(.cancel) {
                    dismiss()
                }
            } else {
                ToolbarButton.close {
                    dismiss()
                }
            }
        }

        if isEditable {
            ToolbarItem(placement: .topBarTrailing) {
                Button(.done) {
                    coordinate = draftCoordinate
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Инфраструктура

    private static func cameraPosition(for coordinate: GeoCoordinate) -> MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: coordinate.locationCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

// MARK: - Превью

private extension CoordinateMapFullScreenView {
    static let previewCoordinate = GeoCoordinate(
        latitude: 41.89021,
        longitude: 12.49223,
        horizontalAccuracy: 12
    )

    static func makePreview(locale: Locale, colorScheme: ColorScheme, isEditable: Bool) -> some View {
        @Previewable @State var coordinate = previewCoordinate

        return Group {
            if isEditable {
                CoordinateMapFullScreenView(coordinate: $coordinate, title: "map.location")
            } else {
                CoordinateMapFullScreenView(coordinate: coordinate, title: "map.location")
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Read. Light - RU") {
    CoordinateMapFullScreenView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, isEditable: false)
}

#Preview("Edit. Dark - EN") {
    CoordinateMapFullScreenView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, isEditable: true)
}
