//
//  Date+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import Foundation

extension Date {
    // MARK: - Свойства. Сравнение дат по текущему календарю
    
    var isYesterday: Bool {
        isYesterday()
    }
    
    var isToday: Bool {
        isToday()
    }
    
    var isTomorrow: Bool {
        isTomorrow()
    }
    
    // MARK: - Методы. Сравнение дат с поддержкой календаря
    
    func isYesterday(using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == Date().yesterday(using: calendar).startOfDay(using: calendar)
    }
    
    func isToday(using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == Date().startOfDay(using: calendar)
    }
    
    func isTomorrow(using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == Date().tomorrow(using: calendar).startOfDay(using: calendar)
    }
    
    func isSameDay(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == other.startOfDay(using: calendar)
    }
    
    func isSameWeek(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfWeek(using: calendar) == other.startOfWeek(using: calendar)
    }
    
    func isSameMonth(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfMonth(using: calendar) == other.startOfMonth(using: calendar)
    }
    
    func isSameYear(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfYear(using: calendar) == other.startOfYear(using: calendar)
    }
    
    func isBetween(_ start: Date, and end: Date, using calendar: Calendar = .current) -> Bool {
        self >= start && self <= end
    }
    
    // MARK: - Методы. Разница между датами с поддержкой календаря
    
    func seconds(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.second], using: calendar).second ?? 0
    }
    
    func minutes(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.minute], using: calendar).minute ?? 0
    }
    
    func hours(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.hour], using: calendar).hour ?? 0
    }
    
    func days(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.day], using: calendar).day ?? 0
    }
    
    func months(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.month], using: calendar).month ?? 0
    }
    
    func years(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.year], using: calendar).year ?? 0
    }
    
    // MARK: - Внутренние методы
    
    private func difference(
        from date: Date,
        components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second],
        using calendar: Calendar
    ) -> DateComponents {
        return calendar.dateComponents(components, from: date, to: self)
    }
}
