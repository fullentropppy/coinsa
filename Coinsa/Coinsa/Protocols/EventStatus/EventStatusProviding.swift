//
//  EventStatusProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Protocol

protocol EventStatusProviding: DateRangeProviding {
    var status: EventStatus { get }
}

// MARK: - Default Implementation

extension EventStatusProviding {
    var status: EventStatus {
        let now = Date.now
        if now < startDate {
            return .upcoming
        } else if now >= startDate && now < endDate {
            return .ongoing
        } else {
            return .completed
        }
    }
}
