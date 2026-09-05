//
//  TodayViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import Foundation

/// ViewModel для экрана "Сегодня".
@MainActor
@Observable
final class TodayViewModel {
    // MARK: - Зависимости
    
    private let exchangeRateManager: ExchangeRateManager
    private var selectedLocationID: UUID?
    
    var currentLocations: [Location]
    
    // MARK: - Состояние UI. Общее поведение и оформление
    
    var today: Date {
        CivilDateTime.now.storedDate
    }
    
    var todayRange: ClosedRange<Date> {
        today.startOfDay(using: .utc)...today.endOfDay(using: .utc)
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
            selectedLocation.baseCurrency == selectedLocation.locationCurrency
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
        DateDisplayFormatter.format(.now, showsTime: false, showsWeekday: true).capitalized
    }
    
    // MARK: - Состояние UI. Курс обмена
    
    private var loadedRateLocationToBase: Double?
    
    var rateLocationToBase: Double {
        if let loadedRateLocationToBase {
            return loadedRateLocationToBase
        } else if let selectedLocation {
            return selectedLocation.rateLocationToBase
        } else {
            return 1
        }
    }
    
    var rateBaseToLocal: Double {
        rateLocationToBase > 0 ? (1 / rateLocationToBase) : 0
    }
    
    var rateRefreshKey: Date {
        selectedLocation?.updatedAt ?? .now
    }
    
    // MARK: - Состояние UI. Расходы за сегодня
    
    var hasTodayExpenses: Bool {
        !todayExpenses.isEmpty
    }
    
    var todayExpenses: [Expense] {
        guard let selectedLocation else { return [] }
        
        return selectedLocation.expenses?
            .filter { todayRange.contains($0.civilDateTime.storedDate) }
            .sorted { $0.civilDateTime > $1.civilDateTime }
        ?? []
    }
    
    // MARK: - Инициализация
    
    /// Создает ViewModel для экрана "Сегодня".
    /// - Parameters:
    ///   - currentLocations: Доступные на сегодня локации.
    ///   - selectedLocationID: Идентификатор выбранной локации (из настроек).
    init(currentLocations: [Location], selectedLocationID: UUID?) {
        let exchangeRateService = ExchangeRateProvider(service: HexarateService())
        let exchangeRateManager = ExchangeRateManager(provider: exchangeRateService)
        
        self.exchangeRateManager = exchangeRateManager
        self.currentLocations = currentLocations
        self.selectedLocationID = selectedLocationID
        self.loadedRateLocationToBase = nil
    }
    
    // MARK: - Курс обмена
    
    func loadInitialRateIfNeeded() {
        guard let selectedLocation else { return }
        
        loadedRateLocationToBase = nil
        
        guard !isHomeLocation else { return }
        
        exchangeRateManager.requestRefresh(
            from: selectedLocation.locationCurrency,
            to: selectedLocation.baseCurrency
        ) { [weak self] rate in
            self?.loadedRateLocationToBase = rate
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
        var budgetBaseAmount = location.calculateBudgetAmountForToday()
        var expensesAmountBase = location.calculateExpensesAmount(withinDateRange: todayRange)
        
        var budgetLocationAmount: Double?
        var expensesLocationAmount: Double?
        
        if expensesAmountBase > budgetBaseAmount && expensesAmountBase > budgetBaseAmount + budgetBaseAmount * 0.2 {
            budgetBaseAmount = location.budget
            budgetLocationAmount = isHomeLocation ? nil : location.calculateBudgetAmount(in: .location)
            expensesAmountBase = location.calculateExpensesAmount(in: .base)
            expensesLocationAmount = isHomeLocation ? nil : location.calculateExpensesAmount(in: .location)
        } else {
            budgetLocationAmount = isHomeLocation ? nil : location.calculateBudgetAmountForToday(in: .location)
            expensesLocationAmount = isHomeLocation ? nil : location.calculateExpensesAmount(in: .location, withinDateRange: todayRange)
        }
        
        return EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            budgetBaseAmount: budgetBaseAmount,
            expensesBaseAmount: expensesAmountBase,
            baseCurrency: location.baseCurrency,
            budgetLocationAmount: budgetLocationAmount,
            expensesLocationAmount: expensesLocationAmount,
            locationCurrency: location.locationCurrency
        )
    }
}
