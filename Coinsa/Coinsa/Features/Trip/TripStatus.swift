//
//  TripStatus.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import Foundation

enum TripStatus: String, Codable, CaseIterable {
    // MARK: - Cases
    
    case upcoming = "trip.status.upcoming"
    case ongoing = "trip.status.ongoing"
    case completed = "trip.status.completed"
    
    // MARK: - Computed properties
    
    var localized: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}
