//
//  NowViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import Foundation

struct NowViewModel {
    // MARK: - Stored Properties
    
    let currentLocations: [Location]
    let selectedLocationID: UUID?
    let baseCurrency: Currency
    
    // MARK: - Computed Properties
    
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
    
    var todayExpenses: [Expense] {
        guard let selectedLocation else { return [] }
        
        let today = Date()
        return selectedLocation.expenses
            .filter { $0.date >= today.startOfDay && $0.date < today.endOfDay }
            .sorted { $0.date > $1.date }
    }
    
    var hasTodayExpenses: Bool {
        !todayExpenses.isEmpty
    }
    
    var locationHeaderData: (name: String, duration: Int, startDate: Date, endDate: Date)? {
        guard let selectedLocation else { return nil }
        return (
            name: selectedLocation.name,
            duration: selectedLocation.durationInDays,
            startDate: selectedLocation.startDate,
            endDate: selectedLocation.endDate
        )
    }
    
    func validSelectedLocation(from selectedLocation: Location?) -> Location? {
        guard !currentLocations.isEmpty else { return nil }
        
        if let selectedLocation,
           currentLocations.contains(where: { $0.id == selectedLocation.id }) {
            return selectedLocation
        }
        
        return currentLocations.first
    }
    
    func eventSummaryData(for location: Location) -> EventSummaryData {
        let viewModel = LocationDetailViewModel(
            location: location,
            baseCurrency: baseCurrency
        )
        return viewModel.eventHeaderData
    }
}
