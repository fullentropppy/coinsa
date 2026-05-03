//
//  Date+Components.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

import Foundation

/// Извлечение компонент дат.
extension Date {
    // MARK: - Свойства. Компоненты дат по текущему календарю
    
    /// Секунда даты (0...59).
    var second: Int {
        component(.second)
    }
    
    /// Минута даты (0...59).
    var minute: Int {
        component(.minute)
    }
    
    /// Час даты (0...23).
    var hour: Int {
        component(.hour)
    }
    
    /// День месяца даты (0...31).
    var day: Int {
        component(.day)
    }
    
    /// День недели даты (1...7).
    var weekday: Int {
        component(.weekday)
    }
    
    /// Номер недели месяца даты (1...5).
    var weekOfMonth: Int {
        component(.weekOfMonth)
    }
    
    /// Номер недели года даты (1...53).
    var weekOfYear: Int {
        component(.weekOfYear)
    }
    
    /// Номер месяца даты (1...12).
    var month: Int {
        component(.month)
    }
    
    /// Номер квартала даты (1...4).
    var quarter: Int {
        component(.quarter)
    }
    
    /// Год даты.
    var year: Int {
        component(.year)
    }
    
    // MARK: - Методы. Компоненты дат с поддержкой календаря
    
    /// Возвращает секунду даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Секунда (0...59).
    func second(using calendar: Calendar = .current) -> Int {
        component(.second, using: calendar)
    }
    
    /// Возвращает минуту даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Минута (0...59).
    func minute(using calendar: Calendar = .current) -> Int {
        component(.minute, using: calendar)
    }
    
    /// Возвращает час даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Час (0...23).
    func hour(using calendar: Calendar = .current) -> Int {
        component(.hour, using: calendar)
    }
    
    /// Возвращает день месяца даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: День месяца (1...31).
    func day(using calendar: Calendar = .current) -> Int {
        component(.day, using: calendar)
    }
    
    /// Возвращает день недели даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: День недели (1...7).
    func weekday(using calendar: Calendar = .current) -> Int {
        component(.weekday, using: calendar)
    }
    
    /// Возвращает номер недели месяця дата.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Номер недели в месяце (1...5).
    func weekOfMonth(using calendar: Calendar = .current) -> Int {
        component(.weekOfMonth, using: calendar)
    }
    
    /// Возвращает номер недели года даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Номер недели в году (1...53).
    func weekOfYear(using calendar: Calendar = .current) -> Int {
        component(.weekOfYear, using: calendar)
    }
    
    /// Возвращает номер месяц даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Номер месяца (1...12).
    func month(using calendar: Calendar = .current) -> Int {
        component(.month, using: calendar)
    }
    
    /// Возвращает номер квартала даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Номер квартала (1...4).
    func quarter(using calendar: Calendar = .current) -> Int {
        component(.quarter, using: calendar)
    }
    
    /// Возвращает год даты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Год.
    func year(using calendar: Calendar = .current) -> Int {
        component(.year, using: calendar)
    }
    
    // MARK: - Приватные методы
    
    /// Извлекает числовое значение указанного компонента из даты.
    /// - Parameters:
    ///   - component: Компонент для извлечения.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Значение компонента.
    private func component(_ component: Calendar.Component, using calendar: Calendar = .current) -> Int {
        calendar.component(component, from: self)
    }
}
