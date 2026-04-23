//
//  Date+Boundaries.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

extension Date {
    // MARK: - Свойства. Начало периода по текущему календарю
    
    var startOfMinute: Date {
        startOfMinute()
    }
    
    var startOfHour: Date {
        startOfHour()
    }
    
    var startOfDay: Date {
        startOfDay()
    }
    
    var startOfWeek: Date {
        startOfWeek()
    }
    
    var startOfMonth: Date {
        startOfMonth()
    }
    
    var startOfYear: Date {
        startOfYear()
    }
    
    // MARK: - Свойства. Конец периода по текущему календарю
    
    var endOfMinute: Date {
        endOfMinute()
    }
    
    var endOfHour: Date {
        endOfHour()
    }
    
    var endOfDay: Date {
        endOfDay()
    }
    
    var endOfWeek: Date {
        endOfWeek()
    }
    
    var endOfMonth: Date {
        endOfMonth()
    }
    
    var endOfYear: Date {
        endOfYear()
    }
    
    // MARK: - Методы. Начало периода с поддержкой календаря
    
    func startOfMinute(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month, .day, .hour, .minute], using: calendar)
    }
    
    func startOfHour(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month, .day, .hour], using: calendar)
    }
    
    func startOfDay(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month, .day], using: calendar)
    }
    
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        dateInterval(of: .weekOfYear, using: calendar)?.start ?? self
    }
    
    func startOfMonth(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month], using: calendar)
    }
    
    func startOfYear(using calendar: Calendar = .current) -> Date {
        startOf([.year], using: calendar)
    }
    
    // MARK: - Методы. Конец периода с поддержкой календаря
    
    func endOfMinute(using calendar: Calendar = .current) -> Date {
        endOf(.minute, using: calendar)
    }
    
    func endOfHour(using calendar: Calendar = .current) -> Date {
        endOf(.hour, using: calendar)
    }
    
    func endOfDay(using calendar: Calendar = .current) -> Date {
        endOf(.day, using: calendar)
    }
    
    func endOfWeek(using calendar: Calendar = .current) -> Date {
        endOf(.weekOfYear, using: calendar)
    }
    
    func endOfMonth(using calendar: Calendar = .current) -> Date {
        endOf(.month, using: calendar)
    }
    
    func endOfYear(using calendar: Calendar = .current) -> Date {
        endOf(.year, using: calendar)
    }
    
    // MARK: - Внутренние методы
    
    private func startOf(_ components: Set<Calendar.Component>, using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents(components, from: self)) ?? self
    }
    
    private func endOf(_ component: Calendar.Component, using calendar: Calendar) -> Date {
        if let endOfInterval = dateInterval(of: component, using: calendar)?.end {
            endOfInterval.addingTimeInterval(-1)
        } else {
            self
        }
    }
    
    private func dateInterval(of component: Calendar.Component, using calendar: Calendar) -> DateInterval? {
        calendar.dateInterval(of: component, for: self)
    }
}
