//
//  Date+Comparison.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import Foundation

/// Сравнение и вычисление разницы дат.
extension Date {
    // MARK: - Свойства. Сравнение дат по текущему календарю
    
    /// Признак того, что дата является вчерашним днем.
    var isYesterday: Bool {
        isYesterday()
    }
    
    /// Признак того, что дата является текущим днем.
    var isToday: Bool {
        isToday()
    }
    
    /// Признак того, что дата является завтрашним днем.
    var isTomorrow: Bool {
        isTomorrow()
    }
    
    // MARK: - Методы. Сравнение дат с поддержкой календаря
    
    /// Определяет, является ли дата вчерашним днем.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если дата - вчера.
    func isYesterday(using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == Date().yesterday(using: calendar).startOfDay(using: calendar)
    }
    
    /// Определяет, является ли дата сегодняшним днем.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если дата - сегодня.
    func isToday(using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == Date().startOfDay(using: calendar)
    }
    
    /// Определяет, является ли дата завтрашним днем.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если дата - завтра.
    func isTomorrow(using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == Date().tomorrow(using: calendar).startOfDay(using: calendar)
    }
    
    /// Определяет, находится ли дата в том же дне, что и другая дата.
    /// - Parameters:
    ///   - other: Другая дата для сравнения.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если обе даты относятся к одному дню.
    func isSameDay(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfDay(using: calendar) == other.startOfDay(using: calendar)
    }
    
    /// Определяет, находится ли дата в той же неделе, что и другая дата.
    /// - Parameters:
    ///   - other: Другая дата для сравнения.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если обе даты относятся к одной неделе.
    func isSameWeek(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfWeek(using: calendar) == other.startOfWeek(using: calendar)
    }
    
    /// Определяет, находится ли дата в том же месяце, что и другая дата.
    /// - Parameters:
    ///   - other: Другая дата для сравнения.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если обе даты относятся к одному месяцу.
    func isSameMonth(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfMonth(using: calendar) == other.startOfMonth(using: calendar)
    }
    
    /// Определяет, находится ли дата в том же году, что и другая дата.
    /// - Parameters:
    ///   - other: Другая дата для сравнения.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если обе даты относятся к одному году.
    func isSameYear(as other: Date, using calendar: Calendar = .current) -> Bool {
        self.startOfYear(using: calendar) == other.startOfYear(using: calendar)
    }
    
    /// Определяет, находится ли дата между двумя другими датами (включительно).
    /// - Parameters:
    ///   - start: Начальная граница интервала.
    ///   - end: Конечная граница интервала.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: `true`, если дата лежит в интервале `[start, end]`, иначе `false`.
    func isBetween(_ start: Date, and end: Date, using calendar: Calendar = .current) -> Bool {
        self >= start && self <= end
    }
    
    // MARK: - Методы. Разница между датами с поддержкой календаря
    
    /// Возвращает количество секунд от указанной даты.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество полных секунд.
    func seconds(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.second], using: calendar).second ?? 0
    }
    
    /// Возвращает количество минут от указанной даты.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество полных минут.
    func minutes(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.minute], using: calendar).minute ?? 0
    }
    
    /// Возвращает количество часов от указанной даты.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество полных часов.
    func hours(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.hour], using: calendar).hour ?? 0
    }
    
    /// Возвращает количество дней от указанной даты.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество полных дней.
    func days(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.day], using: calendar).day ?? 0
    }
    
    /// Возвращает количество месяцев от указанной даты.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество полных месяцев.
    func months(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.month], using: calendar).month ?? 0
    }
    
    /// Возвращает количество лет от указанной даты.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - calendar: Календарь для вычислений. По умолчанию - `.current`.
    /// - Returns: Количество полных лет.
    func years(from date: Date, using calendar: Calendar = .current) -> Int {
        return difference(from: date, components: [.year], using: calendar).year ?? 0
    }
    
    // MARK: - Внутренние методы
    
    /// Вычисляет разницу от указанной даты в указанных компонентах.
    /// - Parameters:
    ///   - date: Дата, относительно которой вычисляется разница.
    ///   - components: Набор компонентов, которые требуется извлечь из разницы.
    ///   - calendar: Календарь для вычислений.
    /// - Returns: Структура `DateComponents` с заполненными запрошенными полями.
    private func difference(
        from date: Date,
        components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second],
        using calendar: Calendar
    ) -> DateComponents {
        return calendar.dateComponents(components, from: date, to: self)
    }
}
