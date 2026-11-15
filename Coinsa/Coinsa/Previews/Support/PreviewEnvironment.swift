//
//  PreviewEnvironment.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation
import SwiftData

/// Окружение превью с отдельным хранилищем и настройками без автоматического определения данных.
@MainActor
struct PreviewEnvironment {
    let container: ModelContainer
    let settingsStore: AppSettingsStore

    /// Создает окружение с синтетическими поездками без обращения к хранилищу приложения и CloudKit.
    /// - Parameter trips: Поездки, которые требуется добавить в отдельный контейнер.
    init(trips: [Trip] = []) {
        container = Self.makeContainer(with: trips)
        settingsStore = Self.makeSettingsStore()
    }

    /// Создает контейнер в памяти с отключенными CloudKit и автоматическим сохранением.
    /// - Parameter trips: Синтетические поездки для вставки вместе со связанными моделями.
    static func makeContainer(with trips: [Trip] = []) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)

        do {
            let container = try ModelContainer(
                for: Trip.self, Location.self, Expense.self,
                configurations: configuration
            )
            let context = container.mainContext
            context.autosaveEnabled = false
            trips.forEach { context.insert($0) }
            try context.save()
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }

    /// Создает отдельные настройки с отключенными автоматической загрузкой курсов и геолокацией.
    static func makeSettingsStore() -> AppSettingsStore {
        guard let defaults = UserDefaults(suiteName: "Coinsa.Preview.\(UUID().uuidString)") else {
            fatalError("Failed to create preview settings")
        }

        let settingsStore = AppSettingsStore(defaults: defaults)
        settingsStore.fetchExpenseExchangeRateOnline = false
        settingsStore.detectPlaceOfExpense = false
        return settingsStore
    }
}
