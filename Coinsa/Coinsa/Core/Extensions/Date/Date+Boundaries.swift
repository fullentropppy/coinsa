//
//  Date+Boundaries.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

extension Date {
    // MARK: - Computed Properties
    
    var startOfMinute: Date {
        startOf([.year, .month, .day, .hour, .minute])
    }
    
    var endOfMinute: Date {
        endOf(.minute)
    }
    
    var startOfHour: Date {
        startOf([.year, .month, .day, .hour])
    }
    
    var endOfHour: Date {
        endOf(.hour)
    }
    
    var startOfDay: Date {
        startOf([.year, .month, .day])
    }
    
    var endOfDay: Date {
        endOf(.day)
    }
    
    var startOfWeek: Date {
        dateInterval(of: .weekOfYear)?.start ?? self
    }
    
    var endOfWeek: Date {
        endOf(.weekOfYear)
    }
    
    var startOfMonth: Date {
        startOf([.year, .month])
    }
    
    var endOfMonth: Date {
        endOf(.month)
    }
    
    var startOfYear: Date {
        startOf([.year])
    }
    
    var endOfYear: Date {
        endOf(.year)
    }
    
    // MARK: - Private Methods
    
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
