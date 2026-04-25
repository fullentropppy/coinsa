//
//  TripDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation

struct TripDetailViewModel {
    // MARK: - Хранимые свойства

    let trip: Trip
    
    // MARK: - Вычисляемые свойства
    
    var showsFullHeader: Bool {
        !trip.locations.isEmpty
    }
    
    var eventHeaderData: EventSummaryData {
        let plannedAmount = trip.calculatePlannedAmount(asBaseCurrency: true)
        let actualAmount = trip.calculateActualAmount(asBaseCurrency: true)
        
        return EventSummaryData(
            badgeProvider: Trip.self,
            dateRangeProvider: trip,
            plannedBaseAmount: plannedAmount,
            actualBaseAmount: actualAmount,
            baseCurrency: trip.baseCurrency
        )
    }

    var eventAnalyticsData: EventCategoryAnalyticsData {
        let budgetByCategory = trip.calculateBudgetByCategory(asBaseCurrency: true)
        let expenseByCategory = trip.calculateExpenseByCategory(asBaseCurrency: true)

        return EventCategoryAnalyticsData(
            dateRange: trip.range,
            baseCurrency: trip.baseCurrency,
            localCurrency: nil,
            budgetByCategory: slices(from: budgetByCategory, localValues: nil),
            expenseByCategory: slices(from: expenseByCategory, localValues: nil)
        )
    }
    
    var groupedLocations: [(status: EventStatus, locations: [Location])] {
        let grouped = Dictionary(grouping: trip.locations) { $0.status }
        let statusOrder: [EventStatus] = [.ongoing, .upcoming, .completed]
        
        return statusOrder.compactMap { status in
            guard var locationsForStatus = grouped[status] else { return nil }
            
            switch status {
            case .ongoing: locationsForStatus.sort { $0.startDate > $1.startDate }
            case .upcoming: locationsForStatus.sort { $0.startDate < $1.startDate }
            case .completed: locationsForStatus.sort { $0.endDate > $1.endDate }
            }
            
            return (status, locationsForStatus)
        }
    }
    
    // MARK: - Инициализация

    init(trip: Trip) {
        self.trip = trip
    }

    // MARK: - Приватные методы

    private func slices(
        from baseValues: [ExpenseCategory: Double],
        localValues: [ExpenseCategory: Double]?
    ) -> [CategoryAnalyticsSlice] {
        ExpenseCategory.allCases.map { category in
            CategoryAnalyticsSlice(
                category: category,
                baseAmount: baseValues[category] ?? 0,
                localAmount: localValues?[category]
            )
        }
    }
}
