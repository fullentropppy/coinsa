//
//  PreviewDataFactory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@MainActor
struct PreviewDataFactory {
    // MARK: - Nested types

    final class Builder {
        // MARK: - Stored properties
        
        private var includeTrips = true
        private var includeLocations = true
        private var includeBudgets = true
        private var includeExpenses = true

        // MARK: - Public methods. Builder parameters
        
        func withTrips(_ value: Bool) -> Builder {
            includeTrips = value
            return self
        }
        
        func withLocations(_ value: Bool) -> Builder {
            includeLocations = value
            return self
        }
        
        func withBudgets(_ value: Bool) -> Builder {
            includeBudgets = value
            return self
        }

        func withExpenses(_ value: Bool) -> Builder {
            includeExpenses = value
            return self
        }

        // MARK: - Public methods. Building
        
        func buildContainer() -> ModelContainer {
            return makeContainer(with: buildData())
        }
        
        func buildData() -> [Trip] {
            return includeTrips ? makeSampleTrips(
                includeLocations: includeLocations,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses
            ) : []
        }
    
        func buildFirstTrip() -> Trip {
            return buildData().first!
        }
        
        func buildFirstLocation() -> Location {
            return buildFirstTrip().locations.first!
        }
        
        func buildFirstBudget() -> Budget {
            return buildFirstLocation().budgets.first!
        }
        
        func buildFirstExpense() -> Expense {
            return buildFirstLocation().expenses.first!
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

        return container
    }
    
    // MARK: - Private methods. Sample Data

    private static func makeSampleTrips(
        includeLocations: Bool,
        includeBudgets: Bool,
        includeExpenses: Bool
    ) -> [Trip] {
        let now = Date()
        let day: TimeInterval = 86400

        let japanTrip = Trip(
            name: "Japan",
            startDate: now,
            endDate: now.addingTimeInterval(day * 10)
        )

        let koreaTrip = Trip(
            name: "South Korea",
            startDate: now.addingTimeInterval(day * 20),
            endDate: now.addingTimeInterval(day * 30)
        )
        
        if includeLocations {
            let tokyo = makeLocation(
                name: "Tokyo",
                currency: "JPY",
                rate: 0.007,
                trip: japanTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses
            )
            
            let kyoto = makeLocation(
                name: "Kyoto",
                currency: "JPY",
                rate: 0.007,
                trip: japanTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses
            )
            
            japanTrip.locations = [tokyo, kyoto]
            
            let seoul = makeLocation(
                name: "Seoul",
                currency: "KRW",
                rate: 0.00075,
                trip: koreaTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses
            )

            let busan = makeLocation(
                name: "Busan",
                currency: "KRW",
                rate: 0.00075,
                trip: koreaTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses
            )

            koreaTrip.locations = [seoul, busan]
        }

        return [japanTrip, koreaTrip]
    }

    private static func makeLocation(
        name: String,
        currency: String,
        rate: Double,
        trip: Trip,
        includeBudgets: Bool,
        includeExpenses: Bool
    ) -> Location {
        let location = Location(
            name: name,
            startDate: trip.startDate,
            endDate: trip.endDate,
            locationCurrencyCode: currency,
            exchangeRateLocationToBaseCurrency: rate,
            trip: trip
        )

        if includeBudgets {
            location.budgets = [
                Budget(category: .food, amountInBaseCurrency: 300, location: location),
                Budget(category: .transport, amountInBaseCurrency: 150, location: location)
            ]
        }

        if includeExpenses {
            location.expenses = [
                Expense(
                    amountInLocationCurrency: 40,
                    exchangeRateLocationToBaseCurrency: rate,
                    category: .food,
                    location: location,
                    comment: "Restaurant"
                ),
                Expense(
                    amountInLocationCurrency: 20,
                    exchangeRateLocationToBaseCurrency: rate,
                    category: .transport,
                    location: location
                )
            ]
        }

        return location
    }
}
