//
//  PreviewDataBuilder.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@MainActor
struct PreviewBuilder {
    // MARK: - Nested types

    final class Builder {
        // MARK: - Stored properties

        private var scenario: PreviewScenario = .japan
        private var options = PreviewOptions()

        // MARK: - Public methods. Builder parameters

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

        // MARK: - Public methods. Container

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

        func fetchBudget(from container: ModelContainer, at index: Int = 0) -> Budget {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Budget.location.trip.startDate, order: .forward)]
            )
        }

        func fetchExpense(from container: ModelContainer, at index: Int = 0) -> Expense {
            fetchItem(
                from: container,
                at: index,
                sortBy: [SortDescriptor(\Expense.location.trip.startDate, order: .forward)]
            )
        }

        // MARK: - Public methods. Sample data

        func buildData() -> [Trip] {
            PreviewGenerator.makeTrips(for: scenario, options: options)
        }

        func getTrip(from data: [Trip], at index: Int = 0) -> Trip {
            data[index]
        }

        func getLocation(from data: [Trip], tripIndex: Int = 0, locationIndex: Int = 0) -> Location {
            getTrip(from: data, at: tripIndex).locations[locationIndex]
        }

        func getBudget(
            from data: [Trip],
            tripIndex: Int = 0,
            locationIndex: Int = 0,
            budgetIndex: Int = 0
        ) -> Budget {
            getLocation(from: data, tripIndex: tripIndex, locationIndex: locationIndex).budgets[budgetIndex]
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

    // MARK: - Public methods

    static func builder() -> Builder {
        Builder()
    }

    // MARK: - Private methods. Container

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
