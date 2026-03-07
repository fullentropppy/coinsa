//
//  StatusProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Protocol

protocol StatusProviding: DateRangeProviding {
    var status: EventStatus { get }
}

// MARK: - Default Implementation

extension StatusProviding {
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
