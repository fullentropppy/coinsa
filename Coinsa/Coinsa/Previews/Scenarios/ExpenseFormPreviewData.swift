//
//  ExpenseFormPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 14.11.2026.
//

import SwiftData

/// Синтетический черновик и отдельное окружение для превью формы траты.
@MainActor
struct ExpenseFormPreviewData {
    let container: ModelContainer
    let settingsStore: AppSettingsStore
    let viewModel: ExpenseEditViewModel?

    /// Создает данные в памяти без CloudKit, с локальными курсами и настройками без автоматических запросов.
    /// - Parameter isEditing: Подготавливать существующую трату или черновик новой.
    init(isEditing: Bool) {
        let environment = PreviewEnvironment()
        container = environment.container
        settingsStore = environment.settingsStore
        let context = container.mainContext
        let exchangeRateProvider = ExchangeRateProvider(service: PreviewExchangeRateService())

        if isEditing {
            let expense = PreviewGenerator.makeExampleExpense()
            context.insert(expense)
            viewModel = ExpenseEditViewModel(
                forEdit: expense,
                exchangeRateProvider: exchangeRateProvider
            )
        } else {
            let location = PreviewGenerator.makeExampleLocation()
            context.insert(location)
            viewModel = ExpenseEditViewModel(
                forCreateWith: location,
                exchangeRateProvider: exchangeRateProvider
            )
        }
        try! context.save()
    }
}
