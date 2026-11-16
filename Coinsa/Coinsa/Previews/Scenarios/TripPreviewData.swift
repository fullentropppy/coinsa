//
//  TripPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftData

/// Синтетическая поездка и отдельное окружение для превью редактора и деталей.
@MainActor
struct TripPreviewData {
    let container: ModelContainer
    let settingsStore: AppSettingsStore
    let trip: Trip
    let viewModel: TripEditViewModel?

    /// Создает поездку в памяти без CloudKit и общих настроек приложения.
    /// - Parameters:
    ///   - previewTrip: Предопределенная поездка для редактора или деталей.
    ///   - isEditing: Подготавливать черновик существующей поездки или новой.
    ///   - includeLocations: Добавлять пример локаций поездки.
    ///   - includeExpenses: Добавлять пример трат в созданные локации.
    init(_ previewTrip: PreviewTrip = .balkans, isEditing: Bool = true, includeLocations: Bool = false, includeExpenses: Bool = false) {
        let environment = PreviewEnvironment()
        container = environment.container
        settingsStore = environment.settingsStore
        let context = container.mainContext

        trip = PreviewGenerator.makeExampleTrip(
            previewTrip,
            includeLocations: includeLocations,
            includeExpenses: includeExpenses
        )
        context.insert(trip)
        try! context.save()

        viewModel = isEditing
            ? TripEditViewModel(forEdit: trip)
            : TripEditViewModel(forCreateWith: .defaultValue)
    }
}
