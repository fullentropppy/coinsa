//
//  Date+Boundaries.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

extension Date {
    // MARK: - Начало периода
    
    var startOfMinute: Date {
        startOf([.year, .month, .day, .hour, .minute])
    }
    
    var startOfHour: Date {
        startOf([.year, .month, .day, .hour])
    }
    
    var startOfDay: Date {
        startOf([.year, .month, .day])
    }
    
    var startOfWeek: Date {
        dateInterval(of: .weekOfYear)?.start ?? self
    }
    
    var startOfMonth: Date {
        startOf([.year, .month])
    }
    
    var startOfYear: Date {
        startOf([.year])
    }
    
    // MARK: - Конец периода
    
    var endOfMinute: Date {
        endOf(.minute)
    }
    
    var endOfHour: Date {
        endOf(.hour)
    }
    
    var endOfDay: Date {
        endOf(.day)
    }
    
    var endOfWeek: Date {
        endOf(.weekOfYear)
    }
    
    var endOfMonth: Date {
        endOf(.month)
    }
    
    var endOfYear: Date {
        endOf(.year)
    }
    
    // MARK: - Внутренние методы
    
    private func startOf(_ components: Set<Calendar.Component>) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents(components, from: self)) ?? self
    }
    
    private func endOf(_ component: Calendar.Component) -> Date {
        if let endOfInterval = dateInterval(of: component)?.end {
            endOfInterval - 1
        } else {
            self
        }
    }
    
    private func dateInterval(of component: Calendar.Component) -> DateInterval? {
        Calendar.current.dateInterval(of: component, for: self)
    }
}
