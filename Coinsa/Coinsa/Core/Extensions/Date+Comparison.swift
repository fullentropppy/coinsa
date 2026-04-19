//
//  Date+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import Foundation

extension Date {
    // MARK: - Сравнение дат
    
    var isYesterday: Bool {
        self.startOfDay == Date().yesterday.startOfDay
    }
    
    var isToday: Bool {
        self.startOfDay == Date().startOfDay
    }
    
    var isTomorrow: Bool {
        self.startOfDay == Date().tomorrow.startOfDay
    }
    
    func isSameDay(as other: Date) -> Bool {
        self.startOfDay == other.startOfDay
    }
    
    func isSameWeek(as other: Date) -> Bool {
        self.startOfWeek == other.startOfWeek
    }
    
    func isSameMonth(as other: Date) -> Bool {
        self.startOfMonth == other.startOfMonth
    }
    
    func isSameYear(as other: Date) -> Bool {
        self.startOfYear == other.startOfYear
    }
    
    func isBetween(_ start: Date, and end: Date) -> Bool {
        self >= start && self <= end
    }
    
    // MARK: - Разница между датами
    
    func seconds(from date: Date) -> Int {
        return difference(from: date, components: [.second]).second ?? 0
    }
    
    func minutes(from date: Date) -> Int {
        return difference(from: date, components: [.minute]).minute ?? 0
    }
    
    func hours(from date: Date) -> Int {
        return difference(from: date, components: [.hour]).hour ?? 0
    }
    
    func days(from date: Date) -> Int {
        return difference(from: date, components: [.day]).day ?? 0
    }
    
    func months(from date: Date) -> Int {
        return difference(from: date, components: [.month]).month ?? 0
    }
    
    func years(from date: Date) -> Int {
        return difference(from: date, components: [.year]).year ?? 0
    }
    
    // MARK: - Внутренние методы
    
    private func difference(
        from date: Date,
        components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    ) -> DateComponents {
        return Calendar.current.dateComponents(components, from: date, to: self)
    }
}
