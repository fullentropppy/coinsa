//
//  ExpenseFormPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 14.11.2026.
//

import Foundation
import SwiftData

/// Синтетический черновик и отдельное окружение для превью формы траты.
@MainActor
struct ExpenseFormPreviewData {
    let container: ModelContainer
    let settingsStore: AppSettingsStore
    let viewModel: ExpenseEditViewModel?

    /// Создает данные в памяти без CloudKit и настройки без автоматических запросов.
    /// - Parameter isEditing: Подготавливать существующую трату или черновик новой.
    init(isEditing: Bool) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        container = try! ModelContainer(
            for: Trip.self, Location.self, Expense.self,
            configurations: configuration
        )
        let context = container.mainContext
        context.autosaveEnabled = false

        if isEditing {
            let expense = PreviewGenerator.makeExampleExpense()
            context.insert(expense)
            viewModel = ExpenseEditViewModel(forEdit: expense)
        } else {
            let location = PreviewGenerator.makeExampleLocation()
            context.insert(location)
            viewModel = ExpenseEditViewModel(forCreateWith: location)
        }
        try! context.save()

        let defaults = UserDefaults(suiteName: "Coinsa.ExpenseFormPreview.\(UUID().uuidString)")!
        settingsStore = AppSettingsStore(defaults: defaults)
        settingsStore.fetchExpenseExchangeRateOnline = false
        settingsStore.detectPlaceOfExpense = false
    }
}
