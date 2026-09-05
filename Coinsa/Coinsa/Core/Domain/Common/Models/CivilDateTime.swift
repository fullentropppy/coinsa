//
//  CivilDateTime.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Календарная дата и время без привязки к часовому поясу.
struct CivilDateTime: Comparable, Hashable {
    // MARK: - Статичные свойства
    
    /// Текущая календарная дата и время.
    static var now: CivilDateTime {
        CivilDateTime(.now, using: .current)
    }
    
    // MARK: - Хранимые свойства
    
    /// Дата и время в формате хранения UTC с пользовательскими `year/month/day/hour/minute/second`.
    let storedDate: Date
    
    // MARK: - Вычисляемые свойсва
    
    /// Начало календарного дня в UTC-календаре.
    var startOfDay: Date {
        storedDate.startOfDay(using: .utc)
    }
    
    /// Конец календарного дня в UTC-календаре.
    var endOfDay: Date {
        storedDate.endOfDay(using: .utc)
    }
    
    // MARK: - Инициализация
    
    /// Создает календарную дату и время без привязки к часовому поясу.
    /// - Parameters:
    ///   - date: Дата, из которой считываются компоненты `year/month/day/hour/minute/second`.
    ///   - calendar: Календарь, из которого считываются компоненты. По умолчанию `.utc`.
    init(_ date: Date, using calendar: Calendar = .utc) {
        self.storedDate = date.storedCivilDateTime(using: calendar)
    }
    
    // MARK: - Границы
    
    /// Возвращает начало календарного дня в заданном календаре.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.utc`.
    /// - Returns: Начало дня в указанном календаре  (00:00:00).
    func startOfDay(using calendar: Calendar = .utc) -> Date {
        storedDate.startOfDay(using: calendar)
    }
    
    /// Возвращает конец календарного дня в заданном календаре.
    /// - Parameter calendar: Календарь для вычислений. По умолчанию `.utc`.
    /// - Returns: Конец дня в указанном календаре (23:59:59).
    func endOfDay(using calendar: Calendar = .utc) -> Date {
        storedDate.endOfDay(using: calendar)
    }
    
    // MARK: - Операции
    
    /// Возвращает фактический момент времени из календарной даты и времени.
    /// - Parameter timeZone: Часовой пояс, в котором интерпретируются компоненты. По умолчанию `.current`.
    /// - Returns: Абсолютная дата для хранения как реального момента времени.
    func actualDate(using timeZone: TimeZone = .current) -> Date {
        storedDate.actualDateFromStoredCivilDateTime(using: timeZone)
    }
    
    /// Возвращает календарную дату и время, смещенные на указанное количество дней.
    /// - Parameter days: Количество дней для смещения.
    /// - Returns: Календарная дата и время после смещения.
    func adding(days: Int) -> CivilDateTime {
        CivilDateTime(storedDate.adding(days: days, using: .utc), using: .utc)
    }
    
    // MARK: - Сравнение
    
    /// Сравнивает календарные даты и время по формату хранения.
    /// - Parameters:
    ///   - lhs: Левая календарная дата и время.
    ///   - rhs: Правая календарная дата и время.
    /// - Returns: `true`, если левая дата и время раньше правой.
    static func < (lhs: CivilDateTime, rhs: CivilDateTime) -> Bool {
        lhs.storedDate < rhs.storedDate
    }
}
