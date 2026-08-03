//
//  PlainDate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Календарная дата без времени и часового пояса.
struct PlainDate: Comparable, Hashable {
    // MARK: - Статичные свойства
    
    /// Сегодняшняя календарная дата.
    static var today: PlainDate {
        PlainDate(.now, using: .current)
    }
    
    // MARK: - Свойства объекта
    
    /// Дата в формате хранения UTC 00:00 с пользовательскими `year/month/day`.
    let storedDate: Date
    
    /// Начало календарного дня в UTC-календаре.
    var startOfDay: Date {
        storedDate.startOfDay(using: .utc)
    }
    
    /// Конец календарного дня в UTC-календаре.
    var endOfDay: Date {
        storedDate.endOfDay(using: .utc)
    }
    
    // MARK: - Инициализация
    
    /// Создает календарную дату без времени и часового пояса.
    /// - Parameters:
    ///   - date: Дата, из которой считываются компоненты `year/month/day`.
    ///   - calendar: Календарь, из которого считываются компоненты. По умолчанию `.utc`.
    init(_ date: Date, using calendar: Calendar = .utc) {
        self.storedDate = date.storedPlainDate(using: calendar)
    }
    
    // MARK: - Операции
    
    /// Возвращает календарную дату, смещенную на указанное количество дней.
    /// - Parameter days: Количество дней для смещения.
    /// - Returns: Календарная дата после смещения.
    func adding(days: Int) -> PlainDate {
        PlainDate(storedDate.adding(days: days, using: .utc), using: .utc)
    }
    
    /// Возвращает количество дней между календарными датами.
    /// - Parameter date: Календарная дата, от которой считается разница.
    /// - Returns: Количество дней от переданной даты до текущей.
    func days(from date: PlainDate) -> Int {
        storedDate.days(from: date.storedDate, using: .utc)
    }
    
    // MARK: - Сравнение
    
    /// Сравнивает календарные даты по формату хранения.
    /// - Parameters:
    ///   - lhs: Левая календарная дата.
    ///   - rhs: Правая календарная дата.
    /// - Returns: `true`, если левая дата раньше правой.
    static func < (lhs: PlainDate, rhs: PlainDate) -> Bool {
        lhs.storedDate < rhs.storedDate
    }
}
