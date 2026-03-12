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
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        
        if today > endDay {
            return .completed
        } else if today >= startDay && today <= endDay {
            return .ongoing
        } else {
            return .upcoming
        }
    }
}
