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
        let days = endDate.days(from: startDate)
        return days == 0 ? 1 : Int(days)
    }
    
    var remainingDays: Int {
        let now = Date()
        return now > endDate.endOfDay ? 0 : Int(endDate.days(from: Date())) + 1
    }
    
    var range: ClosedRange<Date> {
        startDate...endDate
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
