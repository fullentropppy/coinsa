//
//  TodayViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import Foundation

@MainActor
@Observable
final class TodayViewModel {
    // MARK: - Зависимости
    
    private let exchangeRateManager: ExchangeRateManager
    private var selectedLocationID: UUID?
    
    var currentLocations: [Location]
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var today: Date {
        .now
    }
    
    var todayRange: ClosedRange<Date> {
        today.startOfDay...today.endOfDay
    }
    
    var hasMultipleLocations: Bool {
        currentLocations.count > 1
    }
    
    var selectedLocation: Location? {
        if let selectedLocationID,
           let location = currentLocations.first(where: { $0.id == selectedLocationID }) {
            location
        } else {
            currentLocations.first
        }
    }
    
    var isHomeLocation: Bool {
        if let selectedLocation {
            selectedLocation.baseCurrency == selectedLocation.localCurrency
        } else {
            false
        }
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
    
    // MARK: - Состояние UI. Курс обмена
    
    private var loadedRateLocalToBase: Double?
    
    var rateLocalToBase: Double {
        if let loadedRateLocalToBase {
            return loadedRateLocalToBase
        } else if let selectedLocation {
            return selectedLocation.rateLocalToBase
        } else {
            return 1
        }
    }
    
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    var rateRefreshKey: Date {
        if let selectedLocation {
            selectedLocation.updatedAt
        } else {
            Date()
        }
    }
    
    // MARK: - Состояние UI. Расходы за сегодня
    
    var hasTodayExpenses: Bool {
        !todayExpenses.isEmpty
    }
    
    var todayExpenses: [Expense] {
        guard let selectedLocation else { return [] }

        return selectedLocation.expenses
            .filter { $0.date.isToday }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Инициализация
    
    init(currentLocations: [Location], selectedLocationID: UUID?) {
        let exchangeRateService = ExchangeRateProvider(service: HexarateService())
        let exchangeRateManager = ExchangeRateManager(provider: exchangeRateService)
        
        self.exchangeRateManager = exchangeRateManager
        self.currentLocations = currentLocations
        self.selectedLocationID = selectedLocationID
        self.loadedRateLocalToBase = nil
    }
    
    // MARK: - Курс обмена
    
    func loadInitialRateIfNeeded() {
        guard let selectedLocation else { return }
        
        loadedRateLocalToBase = nil

        guard !isHomeLocation else { return }
        
        exchangeRateManager.requestRefresh(
            from: selectedLocation.localCurrency,
            to: selectedLocation.baseCurrency
        ) { [weak self] rate in
            self?.loadedRateLocalToBase = rate
        }
    }
    
    // MARK: - Вспомогательные методы
    
    func updateContext(currentLocations: [Location], selectedLocationID: UUID?) {
        self.currentLocations = currentLocations
        self.selectedLocationID = selectedLocationID
    }
    
    func validSelectedLocationID(from selectedLocationID: UUID?) -> UUID? {
        guard !currentLocations.isEmpty else { return nil }
        
        if let selectedLocationID,
           currentLocations.contains(where: { $0.id == selectedLocationID }) {
            return selectedLocationID
        }
        
        return currentLocations.first?.id
    }
    
    func eventSummaryData(for location: Location) -> EventSummaryData {
        let plannedBaseAmount = location.calculatePlannedAmountForToday()
        let plannedLocalAmount = isHomeLocation ? nil : location.calculatePlannedAmountForToday(asBaseCurrency: false)
        let actualAmountBase = location.calculateActualAmount(asBaseCurrency: true, withinDateRange: todayRange)
        let actualAmountLocal = isHomeLocation ? nil : location.calculateActualAmount(asBaseCurrency: false, withinDateRange: todayRange)
        let localCurrency = isHomeLocation ? nil : location.localCurrency

        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            plannedBaseAmount: plannedBaseAmount,
            actualBaseAmount: actualAmountBase,
            baseCurrency: location.baseCurrency,
            plannedLocalAmount: plannedLocalAmount,
            actualLocalAmount: actualAmountLocal,
            localCurrency: localCurrency
        )
    }
}
