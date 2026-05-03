//
//  Date+Boundaries.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.04.2026.
//

import Foundation

/// Вычисление границ компонентов дат.
extension Date {
    // MARK: - Свойства. Начало периода по текущему календарю
    
    /// Первая микросекунда минуты (:00).
    var startOfMinute: Date {
        startOfMinute()
    }
    
    /// Первая микросекунда часа (00:00).
    var startOfHour: Date {
        startOfHour()
    }
    
    /// Первая микросекунда дня (00:00:00).
    var startOfDay: Date {
        startOfDay()
    }
    
    /// Первая микросекунда недели (первый день недели, 00:00:00).
    var startOfWeek: Date {
        startOfWeek()
    }
    
    /// Первая микросекунда месяца (первое число, 00:00:00).
    var startOfMonth: Date {
        startOfMonth()
    }
    
    /// Первая микросекунда года (1 января, 00:00:00).
    var startOfYear: Date {
        startOfYear()
    }
    
    // MARK: - Свойства. Конец периода по текущему календарю
    
    /// Последняя микросекунда минуты (:59).
    var endOfMinute: Date {
        endOfMinute()
    }
    
    /// Последняя микросекунда часа (:59:59).
    var endOfHour: Date {
        endOfHour()
    }
    
    /// Последняя микросекунда дня (23:59:59).
    var endOfDay: Date {
        endOfDay()
    }
    
    /// Последняя микросекунда недели (последний день недели, 23:59:59).
    var endOfWeek: Date {
        endOfWeek()
    }
    
    /// Последняя микросекунда месяца (последнее число, 23:59:59).
    var endOfMonth: Date {
        endOfMonth()
    }
    
    /// Последняя микросекунда года (31 декабря, 23:59:59).
    var endOfYear: Date {
        endOfYear()
    }
    
    // MARK: - Методы. Начало периода с поддержкой календаря
    
    /// Возвращает первую микросекунду минуты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Начало минуты в указанном календаре (:00).
    func startOfMinute(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month, .day, .hour, .minute], using: calendar)
    }
    
    /// Возвращает первую микросекунду часа.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Начало часа в указанном календаре (00:00).
    func startOfHour(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month, .day, .hour], using: calendar)
    }
    
    /// Возвращает первую микросекунду дня.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Начало дня в указанном календаре  (00:00:00).
    func startOfDay(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month, .day], using: calendar)
    }
    
    /// Возвращает первую микросекунду недели.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Начало недели в указанном календаре (первый день недели, 00:00:00).
    ///            Если интервал не может быть определен, возвращается исходная дата.
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        dateInterval(of: .weekOfYear, using: calendar)?.start ?? self
    }
    
    /// Возвращает первую микросекунду месяца.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Начало месяца в указанном календаре (первое число, 00:00:00).
    func startOfMonth(using calendar: Calendar = .current) -> Date {
        startOf([.year, .month], using: calendar)
    }
    
    /// Возвращает первую микросекунду года.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Начало года в указанном календаре (1 января, 00:00:00).
    func startOfYear(using calendar: Calendar = .current) -> Date {
        startOf([.year], using: calendar)
    }
    
    // MARK: - Методы. Конец периода с поддержкой календаря
    
    /// Возвращает последнюю микросекунду минуты.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Конец минуты в указанном календаре (:59).
    func endOfMinute(using calendar: Calendar = .current) -> Date {
        endOf(.minute, using: calendar)
    }
    
    /// Возвращает последнюю микросекунду часа.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Конец часа в указанном календаре (:59:59).
    func endOfHour(using calendar: Calendar = .current) -> Date {
        endOf(.hour, using: calendar)
    }
    
    /// Возвращает последнюю микросекунду дня.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Конец дня в указанном календаре (23:59:59).
    func endOfDay(using calendar: Calendar = .current) -> Date {
        endOf(.day, using: calendar)
    }
    
    /// Возвращает последнюю микросекунду недели.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Конец недели в указанном календаре (последний день недели, 23:59:59).
    func endOfWeek(using calendar: Calendar = .current) -> Date {
        endOf(.weekOfYear, using: calendar)
    }
    
    /// Возвращает последнюю микросекунду месяца.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Конец месяца в указанном календаре (последнее число, 23:59:59).
    func endOfMonth(using calendar: Calendar = .current) -> Date {
        endOf(.month, using: calendar)
    }
    
    /// Возвращает последнюю микросекунду года.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Конец года в указанном календаре (31 декабря, 23:59:59).
    func endOfYear(using calendar: Calendar = .current) -> Date {
        endOf(.year, using: calendar)
    }
    
    // MARK: - Приватные методы
    
    /// Обрезает дату до указанных компонентов. Все более мелкие компоненты обнуляются.
    /// - Parameters:
    ///   - components: Набор компонентов, которые необходимо сохранить.
    ///   - calendar: Календарь для вычислений.
    /// - Returns: Новая дата, содержащая только указанные компоненты.
    ///            В случае ошибки возвращает исходную дату.
    private func startOf(_ components: Set<Calendar.Component>, using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents(components, from: self)) ?? self
    }
    
    /// Вычисляет последнюю микросекунду указанного временного компонента.
    /// - Parameters:
    ///   - component: Компонент, для которого ищется конец.
    ///   - calendar: Календарь для вычислений.
    /// - Returns: Дата, представляющая конец интервала, с вычетом одной микросекунды от конца интервала.
    ///            В случае ошибки возвращает исходную дату.
    private func endOf(_ component: Calendar.Component, using calendar: Calendar) -> Date {
        if let endOfInterval = dateInterval(of: component, using: calendar)?.end {
            endOfInterval.addingTimeInterval(-1)
        } else {
            self
        }
    }
    
    /// Возвращает временной интервал для указанного компонента относительно текущей даты.
    /// - Parameters:
    ///   - component: Компонент, для которого требуется интервал.
    ///   - calendar: Календарь для вычислений.
    /// - Returns: Интервал от начала до конца указанного периода.
    ///            В случае ошибки возвращет `nil`.
    private func dateInterval(of component: Calendar.Component, using calendar: Calendar) -> DateInterval? {
        calendar.dateInterval(of: component, for: self)
    }
}
