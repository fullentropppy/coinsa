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

    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @Binding private var coordinate: Coordinate?
    @State private var draftCoordinate: Coordinate?
    @State private var cameraPosition: MapCameraPosition
    @State private var currentLocationProvider = CurrentLocationProvider()
    @State private var isGeolocating = false
    @State private var isShowingGeolocationError = false

    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let markerTitle: LocalizedStringResource
    private let isEditable: Bool
    private let errorTitle: LocalizedStringResource?
    private let errorMessage: LocalizedStringResource?

    // MARK: - Инициализация

    /// Создает полноэкранную карту для редактирования координаты.
    /// - Parameters:
    ///   - coordinate: Привязка к объекту координат.
    ///   - title: Заголовок навигационной панели.
    ///   - errorTitle: Заголовок предупреждения об ошибке геолокации.
    ///   - errorMessage: Сообщение предупреждения об ошибке геолокации.
    ///   - markerTitle: Заголовок маркера на карте.
    init(
        coordinate: Binding<Coordinate?>,
        title: LocalizedStringResource,
        markerTitle: LocalizedStringResource,
        errorTitle: LocalizedStringResource,
        errorMessage: LocalizedStringResource
    ) {
        let initialCoordinate = coordinate.wrappedValue

        _coordinate = coordinate
        _draftCoordinate = State(initialValue: initialCoordinate)
        _cameraPosition = State(initialValue: Self.cameraPosition(for: initialCoordinate))
        self.title = title
        self.markerTitle = markerTitle
        self.errorTitle = errorTitle
        self.errorMessage = errorMessage
        self.isEditable = true
    }

    /// Создает полноэкранную карту только для чтения.
    /// - Parameters:
    ///   - coordinate: Объект координат для отображения.
    ///   - title: Заголовок навигационной панели.
    ///   - markerTitle: Заголовок маркера на карте.
    init(
        coordinate: Coordinate,
        title: LocalizedStringResource,
        markerTitle: LocalizedStringResource
    ) {
        _coordinate = .constant(coordinate)
        _draftCoordinate = State(initialValue: coordinate)
        _cameraPosition = State(initialValue: Self.cameraPosition(for: coordinate))
        self.title = title
        self.markerTitle = markerTitle
        self.errorTitle = nil
        self.errorMessage = nil
        self.isEditable = false
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            mapContent
                .navigationTitle(title)
                .navigationSubtitle(draftCoordinate?.formattedDescription ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .notificationAlert(
                    isPresented: $isShowingGeolocationError,
                    title: errorTitle ?? .errorUnknown,
                    message: errorMessage ?? .errorUnknown,
                    isError: true
                )
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    mapBottomBar
                }
        }
    }

    // MARK: - Компоненты

    private var mapContent: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            if let draftCoordinate {
                Marker(String(localized: markerTitle), coordinate: draftCoordinate.coreLocationCoordinate)
            }
        }
        .safeAreaPadding(MapLayout.controlsInset)
        .onMapCameraChange(frequency: .continuous) { context in
            if isEditable {
                draftCoordinate = Coordinate(context.camera.centerCoordinate, horizontalAccuracy: nil)
            }
        }
    }

    private var mapBottomBar: some View {
        HStack {
            if !settingsStore.isFloatingButtonOnLeft {
                Spacer()
            }

            if isEditable {
                Button {
                    haptics.trigger(.tap)
                    Task {
                        await determineCurrentLocation()
                    }
                } label: {
                    if isGeolocating {
                        ProgressView()
                    } else {
                        Image(systemName: "location.fill")
                    }
                }
                .disabled(isGeolocating)
                .padding(MapLayout.buttonPadding)
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: .circle)
            } else {
                Button {
                    centerOnSelectedLocation()
                } label: {
                    Image(systemName: "scope")
                }
                .disabled(draftCoordinate == nil)
                .padding(MapLayout.buttonPadding)
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: .circle)
            }
            
            if settingsStore.isFloatingButtonOnLeft {
                Spacer()
            }
        }
        .padding(.horizontal, MapLayout.bottomBarInset)
        .padding(.bottom, MapLayout.bottomBarInset)
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
                    if isEditable {
                        haptics.trigger(.tap)
                    }
                    coordinate = draftCoordinate
                    dismiss()
                }
            }
        }
    }

    // MARK: - Действия

    private func determineCurrentLocation() async {
        isGeolocating = true
        defer { isGeolocating = false }

        do {
            let location = try await currentLocationProvider.requestCurrentLocation()
            let currentCoordinate = Coordinate(location)
            draftCoordinate = currentCoordinate
            cameraPosition = Self.cameraPosition(for: currentCoordinate)
        } catch {
            isShowingGeolocationError = true
        }
    }

    private func centerOnSelectedLocation() {
        cameraPosition = Self.cameraPosition(for: draftCoordinate)
    }

    // MARK: - Инфраструктура

    private static func cameraPosition(for coordinate: Coordinate?) -> MapCameraPosition {
        guard let coordinate else {
            return .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
                )
            )
        }

        return .region(
            MKCoordinateRegion(
                center: coordinate.coreLocationCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

// MARK: - Превью

#Preview("Reading") {
    let coordinate = PreviewGenerator.makeExampleCoordinate()
    FullScreenMapView(
        coordinate: coordinate,
        title: .expenseSubcategoryBreakfast,
        markerTitle: .expensePlaceOfExpense
    )
    .environment(AppSettingsStore())
}

#Preview("Editing") {
    @Previewable @State var coordinate: Coordinate? = PreviewGenerator.makeExampleCoordinate()
    FullScreenMapView(
        coordinate: $coordinate,
        title: .expenseSubcategoryBreakfast,
        markerTitle: .expensePlaceOfExpense,
        errorTitle: .expenseCoordinateErrorTitle,
        errorMessage: .expenseCoordinateErrorMessage
    )
    .environment(AppSettingsStore())
}
