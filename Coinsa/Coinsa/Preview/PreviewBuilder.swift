//
//  PreviewBuilder.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

/// Построитель данных для превью.
@MainActor
struct PreviewBuilder {
    // MARK: - Публичные методы

    /// Создает новый экземпляр построителя.
    static func builder() -> Builder {
        Builder()
    }

    // MARK: - Приватные методы

    /// Создает контейнер SwiftData с указанными поездками.
    /// - Parameter trips: Массив поездок для вставки.
    /// - Returns: Настроенный контейнер с данными в памяти.
    private static func makeContainer(with trips: [Trip]) -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try! ModelContainer(
            for: Trip.self, Location.self, Budget.self, Expense.self,
            configurations: config
        )

        let context = container.mainContext
        trips.forEach { context.insert($0) }
        try! context.save()

        return container
    }

    /// Извлекает элемент из контейнера по индексу и сортировке.
    /// - Parameters:
    ///   - container: Контейнер SwiftData.
    ///   - index: Индекс элемента в массиве.
    ///   - sortBy: Дескрипторы сортировки.
    /// - Returns: Запрошенный элемент.
    private static func fetchItem<T: PersistentModel>(
        from container: ModelContainer,
        at index: Int = 0,
        sortBy: [SortDescriptor<T>]?
    ) -> T {
        let context = container.mainContext
        var descriptor = FetchDescriptor<T>()
        
        if let sortBy {
            descriptor.sortBy = sortBy
        }

        let items = try! context.fetch(descriptor)
        return items[index]
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

        /// Включает/выключает генерацию поездок.
        func withTrips(_ value: Bool) -> Builder {
            options.includeTrips = value
            return self
        }

        /// Включает/выключает генерацию локаций.
        func withLocations(_ value: Bool) -> Builder {
            options.includeLocations = value
            return self
        }

        /// Включает/выключает генерацию бюджетов.
        func withBudgets(_ value: Bool) -> Builder {
            options.includeBudgets = value
            return self
        }

        /// Включает/выключает генерацию расходов.
        func withExpenses(_ value: Bool) -> Builder {
            options.includeExpenses = value
            return self
        }

        /// Устанавливает полные настройки генерации.
        func withOptions(_ value: PreviewOptions) -> Builder {
            options = value
            return self
        }

        // MARK: - Создание контейнера с данными и получение данных

        /// Создает контейнер SwiftData с сгенерированными данными.
        func buildContainer() -> ModelContainer {
            makeContainer(with: buildData())
        }

        /// Извлекает поездку из контейнера.
        func fetchTrip(from container: ModelContainer, at index: Int = 0) -> Trip {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Trip.startDate, order: .forward)]
            )
        }

        /// Извлекает локацию из контейнера.
        func fetchLocation(from container: ModelContainer, at index: Int = 0) -> Location {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Location.startDate, order: .forward)]
            )
        }

        /// Извлекает трату из контейнера.
        func fetchExpense(from container: ModelContainer, at index: Int = 0) -> Expense {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Expense.date, order: .forward)]
            )
        }

        // MARK: - Создание обособленных данных и получение

        /// Генерирует массив поездок согласно настройкам.
        func buildData() -> [Trip] {
            return PreviewGenerator.makeTrips(for: scenario, options: options)
        }

        /// Извлекает поездку из сгенерированных данных.
        func getTrip(from data: [Trip], at index: Int = 0) -> Trip {
            data[index]
        }

        /// Извлекает локацию из сгенерированных данных.
        func getLocation(from data: [Trip], tripIndex: Int = 0, locationIndex: Int = 0) -> Location {
            getTrip(from: data, at: tripIndex).locations![locationIndex]
        }

        /// Извлекает трату из сгенерированных данных.
        func getExpense(
            from data: [Trip],
            tripIndex: Int = 0,
            locationIndex: Int = 0,
            expenseIndex: Int = 0
        ) -> Expense {
            getLocation(from: data, tripIndex: tripIndex, locationIndex: locationIndex).expenses![expenseIndex]
        }
    }
}
