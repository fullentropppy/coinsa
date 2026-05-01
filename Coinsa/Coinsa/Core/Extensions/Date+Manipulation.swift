//
//  Date+Manipulation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

/// Манипуляции с датами.
extension Date {
    // MARK: - Свойства. Смежные дни по текущему календарю
    
    // Вчерашняя дата с прежними компонентами (кроме дня).
    var yesterday: Date {
        yesterday()
    }
    
    // Завтрашнаяя дата с прежними компонентами (кроме дня).
    var tomorrow: Date {
        tomorrow()
    }
    
    // MARK: - Методы. Смежные дни с поддержкой календаря
    
    /// Возвращает вчерашнюю дату с прежними компонентами (кроме дня).
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Вчерашняя дата.
    func yesterday(using calendar: Calendar = .current) -> Date {
        adding(days: -1)
    }
    
    /// Возвращает завтрашнюю дату с прежними компонентами (кроме дня).
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Завтрашняя дата.
    func tomorrow(using calendar: Calendar = .current) -> Date {
        adding(days: 1)
    }
    
    // MARK: - Методы. Добавление компонентов с поддержкой календаря
    
    /// Возвращает дату, увеличенную на заданное количество секунд.
    /// - Parameters:
    ///   - seconds: Количество секунд для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(seconds: Int, using calendar: Calendar = .current) -> Date {
        adding(seconds, .second, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на заданное количество минут.
    /// - Parameters:
    ///   - minutes: Количество минут для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(minutes: Int, using calendar: Calendar = .current) -> Date {
        adding(minutes, .minute, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на заданное количество часов.
    /// - Parameters:
    ///   - hours: Количество часов для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(hours: Int, using calendar: Calendar = .current) -> Date {
        adding(hours, .hour, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на заданное количество дней.
    /// - Parameters:
    ///   - days: Количество дней для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(days: Int, using calendar: Calendar = .current) -> Date {
        adding(days, .day, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на заданное количество недель.
    /// - Parameters:
    ///   - weeks: Количество недель для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(weeks: Int, using calendar: Calendar = .current) -> Date {
        adding(weeks, .weekOfYear, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на заданное количество месяцев.
    /// - Parameters:
    ///   - months: Количество месяцев для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(months: Int, using calendar: Calendar = .current) -> Date {
        adding(months, .month, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на заданное количество лет.
    /// - Parameters:
    ///   - years: Количество лет для добавления (отрицательное значение - вычитание).
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата.
    func adding(years: Int, using calendar: Calendar = .current) -> Date {
        adding(years, .year, using: calendar)
    }
    
    /// Возвращает дату, увеличенную на произвольную комбинацию компонентов.
    /// - Parameters:
    ///   - years: Количество лет. По умолчанию `0`.
    ///   - months: Количество месяцев. По умолчанию `0`.
    ///   - weeks: Количество недель. По умолчанию `0`.
    ///   - days: Количество дней. По умолчанию `0`.
    ///   - hours: Количество часов. По умолчанию `0`.
    ///   - minutes: Количество минут. По умолчанию `0`.
    ///   - seconds: Количество секунд. По умолчанию `0`.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Новая дата или исходная в случае ошибки.
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
    
    /// Добавляет указанное значение к заданному компоненту даты.
    /// - Parameters:
    ///   - value: Количество добавляемых единиц.
    ///   - component: Компонент календаря.
    ///   - calendar: Календарь для вычислений.
    /// - Returns: Новая дата или исходная при ошибке.
    private func adding(
        _ value: Int,
        _ component: Calendar.Component,
        using calendar: Calendar
    ) -> Date {
        calendar.date(byAdding: component, value: value, to: self) ?? self
    }
}
