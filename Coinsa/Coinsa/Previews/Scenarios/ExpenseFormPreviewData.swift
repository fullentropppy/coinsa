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
    // MARK: - Свойства

    let container: ModelContainer
    let settingsStore: AppSettingsStore
    let viewModel: ExpenseEditViewModel?

    // MARK: - Инициализация

    /// Создает данные в памяти без CloudKit, с локальными курсами и настройками без автоматических запросов.
    /// - Parameters:
    ///   - isEditing: Подготавливать существующую трату или черновик новой.
    ///   - isGeneralExpense: Использовать общие траты вместо локации.
    init(isEditing: Bool, isGeneralExpense: Bool = false) {
        let environment = PreviewEnvironment()
        container = environment.container
        settingsStore = environment.settingsStore
        let context = container.mainContext
        let exchangeRateProvider = ExchangeRateProvider(service: PreviewExchangeRateService())

        if isGeneralExpense {
            let trip = PreviewGenerator.makeExampleTrip(includeExpenses: isEditing)
            context.insert(trip)
            if isEditing, let expense = trip.generalExpenses?.first {
                viewModel = ExpenseEditViewModel(forEdit: expense, exchangeRateProvider: exchangeRateProvider)
            } else {
                viewModel = ExpenseEditViewModel(
                    forCreateWith: trip,
                    exchangeAdjustment: settingsStore.exchangeAdjustment,
                    exchangeRateProvider: exchangeRateProvider
                )
            }
        } else if isEditing {
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
