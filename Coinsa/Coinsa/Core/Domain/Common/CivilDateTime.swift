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
    
    static var now: CivilDateTime {
        CivilDateTime(.now, using: .current)
    }
    
    // MARK: - Свойства объекта
    
    let storedDate: Date
    
    var startOfDay: Date {
        storedDate.startOfDay(using: .utc)
    }
    
    var endOfDay: Date {
        storedDate.endOfDay(using: .utc)
    }
    
    // MARK: - Инициализация
    
    init(_ date: Date, using calendar: Calendar = .utc) {
        self.storedDate = date.storedCivilDateTime(using: calendar)
    }
    
    // MARK: - Операции
    
    func actualDate(using timeZone: TimeZone = .current) -> Date {
        storedDate.actualDateFromStoredCivilDateTime(using: timeZone)
    }
    
    func adding(days: Int) -> CivilDateTime {
        CivilDateTime(storedDate.adding(days: days, using: .utc), using: .utc)
    }
    
    // MARK: - Сравнение
    
    static func < (lhs: CivilDateTime, rhs: CivilDateTime) -> Bool {
        lhs.storedDate < rhs.storedDate
    }
}
