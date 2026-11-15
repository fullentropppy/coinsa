//
//  PreviewBuilder.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftData

/// Построитель данных для превью.
@MainActor
struct PreviewBuilder {
    // MARK: - Публичные методы

    /// Создает новый экземпляр построителя.
    static func builder() -> Builder {
        Builder()
    }
}

// MARK: - Построитель превью-данных

extension PreviewBuilder {
    /// Построитель с настраиваемыми параметрами для генерации превью-данных.
    final class Builder {
        // MARK: - Свойства

        private var scenario: PreviewScenario = .japan
        private var options = PreviewOptions()

        // MARK: - Установка параметров построителя

        /// Устанавливает сценарий генерации.
        func withScenario(_ value: PreviewScenario) -> Builder {
            scenario = value
            return self
        }

        /// Включает/выключает генерацию локаций.
        func withLocations(_ value: Bool) -> Builder {
            options.includeLocations = value
            return self
        }

        /// Включает/выключает генерацию расходов.
        func withExpenses(_ value: Bool) -> Builder {
            options.includeExpenses = value
            return self
        }

        // MARK: - Создание контейнера с данными и получение данных

        /// Создает контейнер SwiftData с сгенерированными данными.
        func buildContainer() -> ModelContainer {
            PreviewEnvironment.makeContainer(with: buildData())
        }

        // MARK: - Создание и получение обособленных данных

        /// Генерирует массив поездок согласно настройкам.
        func buildData() -> [Trip] {
            return PreviewGenerator.makeTrips(for: scenario, options: options)
        }

        /// Извлекает поездку из сгенерированных данных.
        func getTrip(from data: [Trip], at index: Int = 0) -> Trip {
            data[index]
        }
    }
}
