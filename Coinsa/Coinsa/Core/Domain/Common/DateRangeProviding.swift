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
    var totalDays: Int { get }
    var elapsedDays: Int { get }
    var remainingDays: Int { get }
    var range: ClosedRange<Date> { get }
}

// MARK: - Стандартная реализация

extension DateRangeProviding {
    // MARK: - Свойства. Расчет по текущему календарю
    
    var status: EventStatus {
        status()
    }
    
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
        startDate...endDate
    }
    
    // MARK: - Методы. Расчет с поддержкой календаря
    
    func status(using calendar: Calendar = .current) -> EventStatus {
        let today = Date().startOfDay(using: calendar)
        
        if today > endDate {
            return .completed
        } else if today.isBetween(startDate, and: endDate, using: calendar) {
            return .ongoing
        } else {
            return .upcoming
        }
    }
    
    func totalDays(using calendar: Calendar = .current) -> Int {
        endDate.days(from: startDate, using: calendar) + 1
    }
    
    func elapsedDays(on date: Date = .now, using calendar: Calendar = .current) -> Int {
        max(0, min(totalDays(using: calendar), date.days(from: startDate, using: calendar) + 1))
    }
    
    func remainingDays(on date: Date = .now, using calendar: Calendar = .current) -> Int {
        min(totalDays(using: calendar), max(0, endDate.days(from: date, using: calendar)))
    }
}
