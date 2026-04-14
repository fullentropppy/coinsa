//
//  EventStatusProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Протокол

protocol EventStatusProviding: DateRangeProviding {
    var status: EventStatus { get }
}

// MARK: - Стандартная реализация

extension EventStatusProviding {
    var status: EventStatus {
        let today = Date().startOfDay
        
        let startDay = startDate.startOfDay
        let endDay = endDate.endOfDay
        
        if today > endDay {
            return .completed
        } else if today.isBetween(startDay, and: endDay) {
            return .ongoing
        } else {
            return .upcoming
        }
    }
}
