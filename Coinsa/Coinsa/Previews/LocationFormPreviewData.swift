//
//  LocationFormPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation
import SwiftData

/// Синтетический черновик и отдельное окружение для превью редактора локации.
@MainActor
struct LocationFormPreviewData {
    let container: ModelContainer
    let settingsStore: AppSettingsStore
    let viewModel: LocationEditViewModel?

    /// Создает данные в памяти без CloudKit, сетевых запросов и общих настроек приложения.
    /// - Parameter isEditing: Подготавливать существующую локацию или черновик новой.
    init(isEditing: Bool) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        container = try! ModelContainer(
            for: Trip.self, Location.self, Expense.self,
            configurations: configuration
        )
        let context = container.mainContext
        context.autosaveEnabled = false

        if isEditing {
            let location = PreviewGenerator.makeExampleLocation()
            context.insert(location)
            viewModel = LocationEditViewModel(forEdit: location, allowsRateRequests: false)
        } else {
            let trip = PreviewGenerator.makeExampleTrip()
            context.insert(trip)
            viewModel = LocationEditViewModel(forCreateWith: trip, allowsRateRequests: false)
        }
        try! context.save()

        let defaults = UserDefaults(suiteName: "Coinsa.LocationFormPreview.\(UUID().uuidString)")!
        settingsStore = AppSettingsStore(defaults: defaults)
        settingsStore.fetchExpenseExchangeRateOnline = false
        settingsStore.detectPlaceOfExpense = false
    }
}
