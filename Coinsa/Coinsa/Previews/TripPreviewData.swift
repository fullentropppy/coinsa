//
//  TripPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation
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
    ///   - isEditing: Подготавливать черновик существующей поездки или новой.
    ///   - includeLocations: Добавлять пример локаций поездки.
    ///   - includeExpenses: Добавлять пример трат в созданные локации.
    init(isEditing: Bool = true, includeLocations: Bool = false, includeExpenses: Bool = false) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        container = try! ModelContainer(
            for: Trip.self, Location.self, Expense.self,
            configurations: configuration
        )
        let context = container.mainContext
        context.autosaveEnabled = false

        trip = PreviewGenerator.makeExampleTrip(
            includeLocations: includeLocations,
            includeExpenses: includeExpenses
        )
        context.insert(trip)
        try! context.save()

        viewModel = isEditing
            ? TripEditViewModel(forEdit: trip)
            : TripEditViewModel(forCreateWith: .defaultValue)

        let defaults = UserDefaults(suiteName: "Coinsa.TripPreview.\(UUID().uuidString)")!
        settingsStore = AppSettingsStore(defaults: defaults)
        settingsStore.fetchExpenseExchangeRateOnline = false
        settingsStore.detectPlaceOfExpense = false
    }
}
