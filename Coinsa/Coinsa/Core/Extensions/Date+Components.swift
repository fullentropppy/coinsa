//
//  Date+Components.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

import Foundation

extension Date {
    // MARK: - Свойства. Компоненты дат по текущему календарю
    
    var second: Int {
        component(.second)
    }
    
    var minute: Int {
        component(.minute)
    }
    
    var hour: Int {
        component(.hour)
    }
    
    var day: Int {
        component(.day)
    }
    
    var weekday: Int {
        component(.weekday)
    }
    
    var weekdayOrdinal: Int {
        component(.weekdayOrdinal)
    }
    
    var weekOfMonth: Int {
        component(.weekOfMonth)
    }
    
    var weekOfYear: Int {
        component(.weekOfYear)
    }
    
    var month: Int {
        component(.month)
    }
    
    var quarter: Int {
        component(.quarter)
    }
    
    var year: Int {
        component(.year)
    }
  
    // MARK: - Методы. Компоненты дат с поддержкой календаря
    
    func second(using calendar: Calendar = .current) -> Int {
        component(.second, using: calendar)
    }
    
    func minute(using calendar: Calendar = .current) -> Int {
        component(.minute, using: calendar)
    }
    
    func hour(using calendar: Calendar = .current) -> Int {
        component(.hour, using: calendar)
    }
    
    func day(using calendar: Calendar = .current) -> Int {
        component(.day, using: calendar)
    }
    
    func weekday(using calendar: Calendar = .current) -> Int {
        component(.weekday, using: calendar)
    }
    
    func weekdayOrdinal(using calendar: Calendar = .current) -> Int {
        component(.weekdayOrdinal, using: calendar)
    }
    
    func weekOfMonth(using calendar: Calendar = .current) -> Int {
        component(.weekOfMonth, using: calendar)
    }
    
    func weekOfYear(using calendar: Calendar = .current) -> Int {
        component(.weekOfYear, using: calendar)
    }
    
    func month(using calendar: Calendar = .current) -> Int {
        component(.month, using: calendar)
    }
    
    func quarter(using calendar: Calendar = .current) -> Int {
        component(.quarter, using: calendar)
    }
    
    func year(using calendar: Calendar = .current) -> Int {
        component(.year, using: calendar)
    }

    // MARK: - Внутренние методы
    
    private func component(_ component: Calendar.Component, using calendar: Calendar = .current) -> Int {
        calendar.component(component, from: self)
    }
}
