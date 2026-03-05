//
//  EventStatus.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

enum EventStatus: String, Codable, CaseIterable {
    // MARK: - Cases

    case upcoming = "event.status.upcoming"
    case ongoing = "event.status.ongoing"
    case completed = "event.status.completed"

    // MARK: - Computed Properties

    var localized: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}
