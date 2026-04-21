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
    // MARK: - Свойства. Расчет по текущему календарю
    
    var totalDays: Int {
        totalDays()
    }
    
    var elapsedDays: Int {
        elapsedDays()
    }
    
    var remainingDays: Int {
        remainingDays()
    }
    
    var range: ClosedRange<Date> {
        range()
    }
    
    var status: EventStatus {
        status()
    }
    
    // MARK: - Методы. Расчет с поддержкой календаря
    
    func totalDays(using calendar: Calendar = .current) -> Int {
        endDate.days(from: startDate, using: calendar) + 1
    }
    
    func elapsedDays(on date: Date = .now, using calendar: Calendar = .current) -> Int {
        max(0, min(totalDays(using: calendar), date.days(from: startDate, using: calendar) + 1))
    }
    
    func remainingDays(on date: Date = .now, using calendar: Calendar = .current) -> Int {
        min(totalDays(using: calendar), max(0, endDate.days(from: date, using: calendar)))
    }
    
    func range(using calendar: Calendar = .current) -> ClosedRange<Date> {
        startDate.startOfDay(using: calendar)...endDate.endOfDay(using: calendar)
    }
    
    func status(using calendar: Calendar = .current) -> EventStatus {
        let today = Date().startOfDay(using: calendar)
        
        let startDay = startDate.startOfDay(using: calendar)
        let endDay = endDate.inclusive(using: calendar)
        
        if today > endDay {
            return .completed
        } else if today.isBetween(startDay, and: endDay, using: calendar) {
            return .ongoing
        } else {
            return .upcoming
        }
    }
}
