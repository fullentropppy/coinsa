//
//  PlainDate.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Календарная дата без времени и часового пояса.
struct PlainDate: Comparable, Hashable {
    // MARK: - Свойства
    
    let storedDate: Date
    
    var startOfDay: Date {
        storedDate.startOfDay(using: .utc)
    }
    
    var endOfDay: Date {
        storedDate.endOfDay(using: .utc)
    }
    
    // MARK: - Инициализация
    
    init(_ date: Date, using calendar: Calendar = .utc) {
        self.storedDate = date.storedPlainDate(using: calendar)
    }
    
    // MARK: - Операции
    
    func adding(days: Int) -> PlainDate {
        PlainDate(storedDate.adding(days: days, using: .utc), using: .utc)
    }
    
    func days(from date: PlainDate) -> Int {
        storedDate.days(from: date.storedDate, using: .utc)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: PlainDate, rhs: PlainDate) -> Bool {
        lhs.storedDate < rhs.storedDate
    }
}

extension PlainDate {
    static var today: PlainDate {
        PlainDate(.now, using: .current)
    }
}
