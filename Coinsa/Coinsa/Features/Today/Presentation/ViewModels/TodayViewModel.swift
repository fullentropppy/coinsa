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
    private var baseCurrency: Currency
    
    var currentLocations: [Location]
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var today: Date {
        .now
    }
    
    var todayRange: ClosedRange<Date> {
        today.startOfDay...today.endOfDay
    }
    
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
    
    init(currentLocations: [Location], selectedLocationID: UUID?, baseCurrency: Currency) {
        let exchangeRateService = ExchangeRateProvider(service: HexarateService())
        let exchangeRateManager = ExchangeRateManager(provider: exchangeRateService)
        
        self.exchangeRateManager = exchangeRateManager
        self.currentLocations = currentLocations
        self.selectedLocationID = selectedLocationID
        self.baseCurrency = baseCurrency
        self.loadedRateLocalToBase = nil
    }
    
    func updateContext(
        currentLocations: [Location],
        selectedLocationID: UUID?,
        baseCurrency: Currency
    ) {
        self.currentLocations = currentLocations
        self.selectedLocationID = selectedLocationID
        self.baseCurrency = baseCurrency
    }
    
    // MARK: - Курс обмена
    
    func loadInitialRateIfNeeded() {
        guard let selectedLocation else { return }
        
        loadedRateLocalToBase = nil

        guard selectedLocation.localCurrency != baseCurrency else { return }
        
        exchangeRateManager.requestRefresh(
            from: selectedLocation.localCurrency,
            to: baseCurrency
        ) { [weak self] rate in
            self?.loadedRateLocalToBase = rate
        }
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
