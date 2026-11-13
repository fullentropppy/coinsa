//
//  TripDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation

/// ViewModel для детального экрана поездки.
struct TripDetailViewModel {
    // MARK: - Хранимые свойства

    let trip: Trip
    
    // MARK: - Вычисляемые свойства
    
    var showsFullHeader: Bool {
        trip.hasLocations
    }
    
    var eventHeaderData: EventSummaryData {
        let budgetAmount = trip.calculateBudgetAmount(inHomeCurrency: true)
        let expensesAmount = trip.calculateExpensesAmount(inHomeCurrency: true)
        
        return EventSummaryData(
            badgeProvider: Trip.self,
            dateRangeProvider: trip,
            budgetHomeAmount: budgetAmount,
            expensesHomeAmount: expensesAmount,
            homeCurrency: trip.homeCurrency
        )
    }

    var eventAnalyticsData: EventCategoryAnalyticsData {
        let baseBudget = trip.calculateBudgetAmount(inHomeCurrency: true)
        let expensesAmountByCategory = trip.calculateExpensesAmountByCategory(inHomeCurrency: true)
        let expenses = trip.locations?.flatMap { $0.expenses ?? [] } ?? []

        return EventCategoryAnalyticsData(
            dateRangeProvider: trip,
            homeCurrency: trip.homeCurrency,
            locationCurrency: nil,
            baseBudget: baseBudget,
            locationBudget: nil,
            expensesAmountByCategory: slices(from: expensesAmountByCategory, localValues: nil),
            expenses: expenses
        )
    }
    
    var groupedLocations: [(status: EventStatus, locations: [Location])] {
        LocationGrouping.grouped(trip.locations ?? [])
    }

    // MARK: - Приватные методы

    private func slices(
        from baseValues: [ExpenseCategory: Double],
        localValues: [ExpenseCategory: Double]?
    ) -> [ExpenseAnalyticsSlice] {
        ExpenseCategory.allCases.map { category in
            ExpenseAnalyticsSlice(
                category: category,
                homeAmount: baseValues[category] ?? 0,
                locationAmount: localValues?[category]
            )
        }
    }
}
