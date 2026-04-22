//
//  PreviewBuilder.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@MainActor
struct PreviewBuilder {
    // MARK: - Публичные методы

    static func builder() -> Builder {
        Builder()
    }

    // MARK: - Внутренние методы

    private static func makeContainer(with trips: [Trip]) -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try! ModelContainer(
            for: Trip.self, Location.self, Expense.self, AppSettings.self,
            configurations: config
        )

        let context = container.mainContext
        trips.forEach { context.insert($0) }
        try! context.save()

        return container
    }

    private static func fetchItem<T: PersistentModel>(
        from container: ModelContainer,
        at index: Int = 0,
        sortBy: [SortDescriptor<T>]
    ) -> T {
        let context = container.mainContext
        var descriptor = FetchDescriptor<T>()
        descriptor.sortBy = sortBy

        let items = try! context.fetch(descriptor)
        return items[index]
    }
}

// MARK: - Построитель превью-данных

extension PreviewBuilder {
    final class Builder {
        // MARK: - Свойства

        private var scenario: PreviewScenario = .japan
        private var options = PreviewOptions()

        // MARK: - Установка параметров построителя

        func withScenario(_ value: PreviewScenario) -> Builder {
            scenario = value
            return self
        }

        func withTrips(_ value: Bool) -> Builder {
            options.includeTrips = value
            return self
        }

        func withLocations(_ value: Bool) -> Builder {
            options.includeLocations = value
            return self
        }

        func withBudgets(_ value: Bool) -> Builder {
            options.includeBudgets = value
            return self
        }

        func withExpenses(_ value: Bool) -> Builder {
            options.includeExpenses = value
            return self
        }

        func withOptions(_ value: PreviewOptions) -> Builder {
            options = value
            return self
        }

        // MARK: - Создание контейнера с данными и получение данных

        func buildContainer() -> ModelContainer {
            makeContainer(with: buildData())
        }

        func fetchTrip(from container: ModelContainer, at index: Int = 0) -> Trip {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Trip.startDate, order: .forward)]
            )
        }

        func fetchLocation(from container: ModelContainer, at index: Int = 0) -> Location {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Location.trip.startDate, order: .forward)]
            )
        }

        func fetchExpense(from container: ModelContainer, at index: Int = 0) -> Expense {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Expense.location.trip.startDate, order: .forward)]
            )
        }

        // MARK: - Создание обособленных данныех и получение

        func buildData() -> [Trip] {
            PreviewGenerator.makeTrips(for: scenario, options: options)
        }

        func getTrip(from data: [Trip], at index: Int = 0) -> Trip {
            data[index]
        }

        func getLocation(from data: [Trip], tripIndex: Int = 0, locationIndex: Int = 0) -> Location {
            getTrip(from: data, at: tripIndex).locations[locationIndex]
        }

        func getExpense(
            from data: [Trip],
            tripIndex: Int = 0,
            locationIndex: Int = 0,
            expenseIndex: Int = 0
        ) -> Expense {
            getLocation(from: data, tripIndex: tripIndex, locationIndex: locationIndex).expenses[expenseIndex]
        }
    }
}
