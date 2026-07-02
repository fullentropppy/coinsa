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
        let baseBudget = trip.calculatePlannedAmount(asBaseCurrency: true)
        let actualAmountByCategory = trip.calculateActualAmountByCategory(asBaseCurrency: true)

        return EventCategoryAnalyticsData(
            dateRange: trip.range,
            baseCurrency: trip.baseCurrency,
            locationCurrency: nil,
            baseBudget: baseBudget,
            localBudget: nil,
            actualAmountByCategory: slices(from: actualAmountByCategory, localValues: nil)
        )
    }
    
    var groupedLocations: [(status: EventStatus, locations: [Location])] {
        guard let locations = trip.locations else { return [] }
        
        let grouped = Dictionary(grouping: locations) { $0.status }
        let statusOrder: [EventStatus] = [.ongoing, .upcoming, .completed]
        
        return statusOrder.compactMap { status in
            guard var locationsForStatus = grouped[status] else { return nil }
            
            switch status {
            case .ongoing:
                locationsForStatus.sort {
                    if $0.startPlainDate != $1.startPlainDate {
                        return $0.startPlainDate > $1.startPlainDate
                    }
                    if $0.totalDays != $1.totalDays {
                        return $0.totalDays < $1.totalDays
                    }
                    return $0.endPlainDate < $1.endPlainDate
                }
                
            case .upcoming:
                locationsForStatus.sort {
                    if $0.startPlainDate != $1.startPlainDate {
                        return $0.startPlainDate < $1.startPlainDate
                    }
                    if $0.totalDays != $1.totalDays {
                        return $0.totalDays < $1.totalDays
                    }
                    return $0.endPlainDate < $1.endPlainDate
                }
                
            case .completed:
                locationsForStatus.sort {
                    if $0.startPlainDate != $1.startPlainDate {
                        return $0.startPlainDate < $1.startPlainDate
                    }
                    if $0.totalDays != $1.totalDays {
                        return $0.totalDays < $1.totalDays
                    }
                    return $0.endPlainDate < $1.endPlainDate
                }
            }
            
            return (status, locationsForStatus)
        }
    }

    // MARK: - Приватные методы

    private func slices(
        from baseValues: [ExpenseCategory: Double],
        localValues: [ExpenseCategory: Double]?
    ) -> [ExpenseAnalyticsSlice] {
        ExpenseCategory.allCases.map { category in
            ExpenseAnalyticsSlice(
                category: category,
                baseAmount: baseValues[category] ?? 0,
                localAmount: localValues?[category]
            )
        }
    }
}
