//
//  TripDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation
import SwiftUI

struct TripDetailViewModel {
    // MARK: - Stored Properties

    let trip: Trip
    let baseCurrency: Currency
    
    // MARK: - Initialization

    init(trip: Trip, baseCurrency: Currency) {
        self.trip = trip
        self.baseCurrency = baseCurrency
    }
    
    // MARK: - Public Methods
    
    func eventHeaderData(locations: [Location]) -> EventSummaryData {
        let plannedAmount = locations.reduce(0) { total, location in
            total + location.calculatePlannedAmount(asBaseCurrency: true)
        }
        let actualAmount = locations.reduce(0) { total, location in
            total + location.calculateActualAmount(asBaseCurrency: true)
        }
        
        return EventSummaryData(
            status: trip.status,
            startDate: trip.startDate,
            endDate: trip.endDate,
            days: trip.durationInDays,
            plannedBaseAmount: plannedAmount,
            actualBaseAmount: actualAmount,
            baseAmountDifference: plannedAmount - actualAmount,
            baseCurrency: baseCurrency,
            plannedLocalAmount: nil,
            actualLocalAmount: nil,
            localAmountDifference: nil,
            localCurrency: nil,
            badgeIcon: Trip.badgeIcon,
            badgeColor: Trip.badgeColor
        )
    }
    
    func groupedLocations(from locations: [Location]) -> [(status: EventStatus, locations: [Location])] {
        let grouped = Dictionary(grouping: locations) { $0.status }
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
}
