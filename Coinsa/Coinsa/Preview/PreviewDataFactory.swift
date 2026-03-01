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

        let koreaTrip = Trip(
            name: "South Korea",
            startDate: now,
            endDate: now.addingTimeInterval(day * 7)
        )
        
        let japanTrip = Trip(
            name: "Japan",
            startDate: now.addingTimeInterval(day * 7),
            endDate: now.addingTimeInterval(day * 21)
        )

        if includeLocations {
            let seoul = makeLocation(
                name: "Seoul",
                startDate: now,
                endDate: now.addingTimeInterval(day * 7),
                currency: "KRW",
                rate: 0.00075,
                trip: koreaTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses,
                locationIndex: 0
            )
            
            koreaTrip.locations = [seoul]
            
            let tokyo = makeLocation(
                name: "Tokyo",
                startDate: now.addingTimeInterval(day * 7),
                endDate: now.addingTimeInterval(day * 14),
                currency: "JPY",
                rate: 0.007,
                trip: japanTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses,
                locationIndex: 1
            )
            
            let kyoto = makeLocation(
                name: "Kyoto",
                startDate: now.addingTimeInterval(day * 14),
                endDate: now.addingTimeInterval(day * 18),
                currency: "JPY",
                rate: 0.007,
                trip: japanTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses,
                locationIndex: 2
            )
            
            let osaka = makeLocation(
                name: "Osaka",
                startDate: now.addingTimeInterval(day * 18),
                endDate: now.addingTimeInterval(day * 21),
                currency: "JPY",
                rate: 0.007,
                trip: japanTrip,
                includeBudgets: includeBudgets,
                includeExpenses: includeExpenses,
                locationIndex: 3
            )
            
            japanTrip.locations = [tokyo, kyoto, osaka]
        }

        return [japanTrip, koreaTrip]
    }

    private static func makeLocation(
        name: String,
        startDate: Date,
        endDate: Date,
        currency: String,
        rate: Double,
        trip: Trip,
        includeBudgets: Bool,
        includeExpenses: Bool,
        locationIndex: Int
    ) -> Location {
        let location = Location(
            name: name,
            startDate: startDate,
            endDate: endDate,
            locationCurrencyCode: currency,
            exchangeRateLocationToBaseCurrency: rate,
            trip: trip
        )

        if includeBudgets {
            switch locationIndex {
            case 0: // Seoul
                location.budgets = [
                    Budget(category: .food, amountInBaseCurrency: 380, location: location),
                    Budget(category: .transport, amountInBaseCurrency: 160, location: location),
                    Budget(category: .activities, amountInBaseCurrency: 280, location: location),
                    Budget(category: .shopping, amountInBaseCurrency: 320, location: location),
                    Budget(category: .medicine, amountInBaseCurrency: 50, location: location)
                ]
            case 1: // Tokyo
                location.budgets = [
                    Budget(category: .food, amountInBaseCurrency: 400, location: location),
                    Budget(category: .transport, amountInBaseCurrency: 200, location: location),
                    Budget(category: .activities, amountInBaseCurrency: 300, location: location)
                ]
            case 2: // Kyoto
                location.budgets = [
                    Budget(category: .food, amountInBaseCurrency: 350, location: location),
                    Budget(category: .transport, amountInBaseCurrency: 150, location: location),
                    Budget(category: .activities, amountInBaseCurrency: 400, location: location),
                    Budget(category: .shopping, amountInBaseCurrency: 250, location: location)
                ]
            case 3: // Osaka
                location.budgets = [
                    Budget(category: .food, amountInBaseCurrency: 500, location: location),
                    Budget(category: .transport, amountInBaseCurrency: 180, location: location),
                    Budget(category: .activities, amountInBaseCurrency: 250, location: location),
                    Budget(category: .shopping, amountInBaseCurrency: 350, location: location)
                ]
            default:
                location.budgets = []
            }
        }

        if includeExpenses {
            let numberOfExpenses = Int.random(in: 4...10)
            var expenses: [Expense] = []
            
            for i in 0..<numberOfExpenses {
                let date = generateRandomDate(from: location.startDate, to: location.endDate)
                let category = ExpenseCategory.allCases.randomElement()!
                let amount = Double.random(in: 10...100)
                let comment = i % 3 == 0 ? generateRandomComment(for: category) : nil
                
                let expense = Expense(
                    date: date,
                    amountInLocationCurrency: amount,
                    exchangeRateLocationToBaseCurrency: rate,
                    category: category,
                    location: location,
                    comment: comment
                )
                expenses.append(expense)
            }
            
            location.expenses = expenses.sorted { $0.date > $1.date }
        }

        return location
    }
    
    private static func generateRandomDate(from startDate: Date, to endDate: Date) -> Date {
        let interval = endDate.timeIntervalSince(startDate)
        let randomInterval = TimeInterval.random(in: 0...interval)
        return startDate.addingTimeInterval(randomInterval)
    }
    
    private static func generateRandomComment(for category: ExpenseCategory) -> String {
        let comments: [ExpenseCategory: [String]] = [
            .food: ["Breakfast", "Lunch", "Street food", "Snaks"],
            .transport: ["Train", "Subway",  "Bus", "Taxi"],
            .activities: ["Museum", "Temple"],
            .shopping: ["Souvenirs", "Clothing"],
            .medicine: ["Pharmacy"],
            .other: ["Miscellaneous"]
        ]
        
        return comments[category]!.randomElement()!
    }
}
