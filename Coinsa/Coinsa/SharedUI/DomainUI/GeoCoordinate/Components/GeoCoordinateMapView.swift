//
//  GeoCoordinateMapView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import MapKit
import SwiftUI

/// Карта с отображением и редактированием географической координаты.
struct GeoCoordinateMapView: View {
    // MARK: - Состояние

    @Binding private var coordinate: GeoCoordinate
    @State private var cameraPosition: MapCameraPosition

    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let isEditable: Bool
    private let accentColor: Color
    private let height: CGFloat

    // MARK: - Инициализация

    init(
        coordinate: Binding<GeoCoordinate>,
        title: LocalizedStringResource,
        isEditable: Bool,
        accentColor: Color = .accentColor,
        height: CGFloat = 220
    ) {
        _coordinate = coordinate
        _cameraPosition = State(initialValue: Self.cameraPosition(for: coordinate.wrappedValue))
        self.title = title
        self.isEditable = isEditable
        self.accentColor = accentColor
        self.height = height
    }

    init(
        coordinate: GeoCoordinate,
        title: LocalizedStringResource,
        accentColor: Color = .accentColor,
        height: CGFloat = 220
    ) {
        self.init(
            coordinate: .constant(coordinate),
            title: title,
            isEditable: false,
            accentColor: accentColor,
            height: height
        )
    }

    // MARK: - Тело View

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            mapContent
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            coordinateText
        }
        .onChange(of: coordinate) { _, newValue in
            cameraPosition = Self.cameraPosition(for: newValue)
        }
    }

    // MARK: - Компоненты

    private var mapContent: some View {
        ZStack {
            readOnlyMap

            if isEditable {
                editIndicator
            }
        }
    }

    private var readOnlyMap: some View {
        Map(position: $cameraPosition, interactionModes: []) {
            Marker(String(localized: title), coordinate: coordinate.coreLocationCoordinate)
        }
    }

    private var editIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, accentColor)
                    .shadow(radius: 3, y: 1)
                    .padding(10)
            }
            Spacer()
        }
        .allowsHitTesting(false)
    }

    private var coordinateText: some View {
        HStack(spacing: 6) {
            Image(systemName: "location")
                .imageScale(.small)

            Text(coordinate.formattedDescription)
                .font(.footnote.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(.secondary)
    }

    private static func cameraPosition(for coordinate: GeoCoordinate) -> MapCameraPosition {
        .region(
            MKCoordinateRegion(
                center: coordinate.coreLocationCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

// MARK: - Превью

private extension GeoCoordinateMapView {
    static let previewCoordinate = GeoCoordinate(
        latitude: 41.89021,
        longitude: 12.49223,
        horizontalAccuracy: 12
    )

    static func makePreview(locale: Locale, colorScheme: ColorScheme, isEditable: Bool) -> some View {
        @Previewable @State var coordinate = previewCoordinate

        return List {
            Section("map.location") {
                GeoCoordinateMapView(
                    coordinate: $coordinate,
                    title: "map.location",
                    isEditable: isEditable
                )
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Read. Light - RU") {
    GeoCoordinateMapView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, isEditable: false)
}

#Preview("Edit. Dark - EN") {
    GeoCoordinateMapView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, isEditable: true)
}
