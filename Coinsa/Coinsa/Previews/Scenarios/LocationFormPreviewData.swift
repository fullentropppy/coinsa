//
//  LocationFormPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

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
        let environment = PreviewEnvironment()
        container = environment.container
        settingsStore = environment.settingsStore
        let context = container.mainContext
        let exchangeRateProvider = ExchangeRateProvider(service: PreviewExchangeRateService())

        if isEditing {
            let location = PreviewGenerator.makeExampleLocation()
            context.insert(location)
            viewModel = LocationEditViewModel(
                forEdit: location,
                allowsRateRequests: false,
                exchangeRateProvider: exchangeRateProvider
            )
        } else {
            let trip = PreviewGenerator.makeExampleTrip()
            context.insert(trip)
            viewModel = LocationEditViewModel(
                forCreateWith: trip,
                allowsRateRequests: false,
                exchangeRateProvider: exchangeRateProvider
            )
        }
        try! context.save()
    }
}
