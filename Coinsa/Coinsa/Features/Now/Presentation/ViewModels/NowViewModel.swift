//
//  NowViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import Foundation

struct NowViewModel {
    // MARK: - Зависимости
    
    let currentLocations: [Location]
    let selectedLocationID: UUID?
    let baseCurrency: Currency
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
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
    
    var navigationSubtitle: String {
        DateDisplayFormatter.format(.now, showsTime: false)
    }
    
    // MARK: - Состояние UI. Данные локации
    
    var locationHeaderData: (name: String, duration: Int, startDate: Date, endDate: Date)? {
        guard let selectedLocation else { return nil }
        return (
            name: selectedLocation.name,
            duration: selectedLocation.durationInDays,
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
        
        let today = Date()
        return selectedLocation.expenses
            .filter { $0.date >= today.startOfDay && $0.date < today.endOfDay }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Вспомогательные методы
    
    func validSelectedLocation(from selectedLocation: Location?) -> Location? {
        guard !currentLocations.isEmpty else { return nil }
        
        if let selectedLocation,
           currentLocations.contains(where: { $0.id == selectedLocation.id }) {
            return selectedLocation
        }
        
        return currentLocations.first
    }
    
    func eventSummaryData(for location: Location) -> EventSummaryData {
        let isHomeLocation = location.localCurrency == baseCurrency
        
        let plannedAmountBase = location.calculatePlannedAmount(asBaseCurrency: true)
        let plannedAmountLocal = isHomeLocation ? nil : location.calculatePlannedAmount(asBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(asBaseCurrency: true)
        let actualAmountLocal = isHomeLocation ? nil : location.calculateActualAmount(asBaseCurrency: false)
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
