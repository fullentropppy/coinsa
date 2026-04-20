//
//  Date+Manipulation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

extension Date {
    // MARK: - Свойства. Смежные дни по текущему календарю
    
    var yesterday: Date {
        yesterday()
    }
    
    var tomorrow: Date {
        tomorrow()
    }
    
    // MARK: - Методы. Смежные дни с поддержкой календаря
    
    func yesterday(using calendar: Calendar = .current) -> Date {
        adding(days: -1)
    }
    
    func tomorrow(using calendar: Calendar = .current) -> Date {
        adding(days: 1)
    }
    
    // MARK: - Методы. Добавление компонентов с поддержкой календаря
    
    func adding(seconds: Int, using calendar: Calendar = .current) -> Date {
        adding(seconds, .second, using: calendar)
    }
    
    func adding(minutes: Int, using calendar: Calendar = .current) -> Date {
        adding(minutes, .minute, using: calendar)
    }
    
    func adding(hours: Int, using calendar: Calendar = .current) -> Date {
        adding(hours, .hour, using: calendar)
    }
    func adding(days: Int, using calendar: Calendar = .current) -> Date {
        adding(days, .day, using: calendar)
    }
    
    func adding(weeks: Int, using calendar: Calendar = .current) -> Date {
        adding(weeks, .weekOfYear, using: calendar)
    }
    
    func adding(months: Int, using calendar: Calendar = .current) -> Date {
        adding(months, .month, using: calendar)
    }
    
    func adding(years: Int, using calendar: Calendar = .current) -> Date {
        adding(years, .year, using: calendar)
    }

    func adding(
        years: Int = 0,
        months: Int = 0,
        weeks: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0,
        using calendar: Calendar = .current
    ) -> Date {
        var dateComponents = DateComponents()
        
        dateComponents.year = years
        dateComponents.month = months
        dateComponents.weekOfYear = weeks
        dateComponents.day = days
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = seconds
        
        return calendar.date(byAdding: dateComponents, to: self) ?? self
    }
    
    // MARK: - Внутренние методы
    
    private func adding(
        _ value: Int,
        _ component: Calendar.Component,
        using calendar: Calendar
    ) -> Date {
        calendar.date(byAdding: component, value: value, to: self) ?? self
    }
}
