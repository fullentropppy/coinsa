//
//  Date+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import Foundation

extension Date {
    // MARK: - Computed Properties
    
    var isYesterday: Bool {
        self.startOfDay == Date().yesterday.startOfDay
    }
    
    var isToday: Bool {
        self.startOfDay == Date().startOfDay
    }
    
    var isTomorrow: Bool {
        self.startOfDay == Date().tomorrow.startOfDay
    }
    
    // MARK: - Public Methods
    
    func isSameDay(as other: Date) -> Bool {
        self.startOfDay == other.startOfDay
    }
    
    func isBetween(_ start: Date, and end: Date) -> Bool {
        self.startOfDay >= start && self.endOfDay <= end
    }
    
    func years(from date: Date) -> Int {
        return difference(from: date, components: [.year]).year ?? 0
    }
    
    func months(from date: Date) -> Int {
        return difference(from: date, components: [.month]).month ?? 0
    }
    
    func days(from date: Date) -> Int {
        return difference(from: date, components: [.day]).day ?? 0
    }
    
    func hours(from date: Date) -> Int {
        return difference(from: date, components: [.hour]).hour ?? 0
    }
    
    func minutes(from date: Date) -> Int {
        return difference(from: date, components: [.minute]).minute ?? 0
    }
    
    func seconds(from date: Date) -> Int {
        return difference(from: date, components: [.second]).second ?? 0
    }
    
    // MARK: - Private Methods
    
    private func difference(
        from date: Date,
        components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    ) -> DateComponents {
        return Calendar.current.dateComponents(components, from: date, to: self)
    }
}
