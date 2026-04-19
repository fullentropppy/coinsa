//
//  DateRangeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Протокол

protocol DateRangeProviding {
    var startDate: Date { get }
    var endDate: Date { get }
    var status: EventStatus { get }
}

// MARK: - Стандартная реализация

extension DateRangeProviding {
    var totalDays: Int {
        let days = endDate.startOfDay.days(from: startDate.startOfDay)
        return days == 0 ? 1 : days + 1
    }
    
    var remainingDays: Int {
        let now = Date()
        return now > endDate.endOfDay ? 0 : Int(endDate.days(from: Date())) + 1
    }
    
    var range: ClosedRange<Date> {
        startDate.startOfDay...endDate.endOfDay
    }
    
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
