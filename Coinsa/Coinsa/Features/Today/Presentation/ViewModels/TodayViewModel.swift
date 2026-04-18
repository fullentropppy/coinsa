//
//  TodayViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import Foundation

struct TodayViewModel {
    // MARK: - Зависимости
    
    let currentLocations: [Location]
    let selectedLocationID: UUID?
    let baseCurrency: Currency
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var today: Date = .now
    var todayRange: ClosedRange<Date> = Date().startOfDay...Date().endOfDay
    
    var selectedLocation: Location? {
        if let selectedLocationID,
           let location = currentLocations.first(where: { $0.id == selectedLocationID }) {
            location
        } else {
            currentLocations.first
        }
    }
    
    var hasMultipleLocations: Bool {
        currentLocations.count > 1
    }
    
    var navigtaionTitle: String {
        if let selectedLocation, !hasMultipleLocations {
            selectedLocation.name
        } else {
            String(localized: .today)
        }
    }
    
    var navigationSubtitle: String {
        DateDisplayFormatter.format(.now, showsTime: false)
    }
    
    // MARK: - Состояние UI. Данные локации
    
    var locationHeaderData: (name: String, duration: Int, startDate: Date, endDate: Date)? {
        guard let selectedLocation else { return nil }
        return (
            name: selectedLocation.name,
            duration: selectedLocation.totalDays,
            startDate: selectedLocation.startDate,
            endDate: selectedLocation.endDate
        )
    }
    
    // MARK: - Состояние UI. Расходы за сегодня
    
    var hasTodayExpenses: Bool {
        !todayExpenses.isEmpty
    }
    
    var todayExpenses: [Expense] {
        guard let selectedLocation else { return [] }

        return selectedLocation.expenses
            .filter { $0.date >= today.startOfDay && $0.date < today.endOfDay }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Вспомогательные методы
    
    func validSelectedLocationID(from selectedLocationID: UUID?) -> UUID? {
        guard !currentLocations.isEmpty else { return nil }
        
        if let selectedLocationID,
           currentLocations.contains(where: { $0.id == selectedLocationID }) {
            return selectedLocationID
        }
        
        return currentLocations.first?.id
    }
    
    func eventSummaryData(for location: Location) -> EventSummaryData {
        let isHomeLocation = location.localCurrency == baseCurrency

        let plannedAmountBase = location.calculatePlannedAmountForToday()
        let plannedAmountLocal = isHomeLocation ? nil : location.calculatePlannedAmountForToday(asBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(asBaseCurrency: true, withinDateRange: todayRange)
        let actualAmountLocal = isHomeLocation ? nil : location.calculateActualAmount(asBaseCurrency: false, withinDateRange: todayRange)
        let localCurrency = isHomeLocation ? nil : location.localCurrency

        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            plannedBaseAmount: plannedAmountBase,
            actualBaseAmount: actualAmountBase,
            baseCurrency: baseCurrency,
            plannedLocalAmount: plannedAmountLocal,
            actualLocalAmount: actualAmountLocal,
            localCurrency: localCurrency
        )
    }
}
