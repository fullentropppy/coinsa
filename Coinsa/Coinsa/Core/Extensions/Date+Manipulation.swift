//
//  Date+Manipulation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

extension Date {
    // MARK: - Смежные дни
    
    var yesterday: Date {
        adding(days: -1)
    }
    
    var tomorrow: Date {
        adding(days: 1)
    }
    
    // MARK: - Добавление компонентов
    
    func adding(seconds: Int) -> Date {
        adding(seconds, .second)
    }
    
    func adding(minutes: Int) -> Date {
        adding(minutes, .minute)
    }
    
    func adding(hours: Int) -> Date {
        adding(hours, .hour)
    }
    func adding(days: Int) -> Date {
        adding(days, .day)
    }
    
    func adding(weeks: Int) -> Date {
        adding(weeks, .weekOfYear)
    }
    
    func adding(months: Int) -> Date {
        adding(months, .month)
    }
    
    func adding(years: Int) -> Date {
        adding(years, .year)
    }

    func adding(
        years: Int = 0,
        months: Int = 0,
        weeks: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0
    ) -> Date {
        var dateComponents = DateComponents()
        
        dateComponents.year = years
        dateComponents.month = months
        dateComponents.weekOfYear = weeks
        dateComponents.day = days
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = seconds
        
        return Calendar.current.date(byAdding: dateComponents, to: self) ?? self
    }
    
    // MARK: - Внутренние методы
    
    private func adding(_ value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
}
