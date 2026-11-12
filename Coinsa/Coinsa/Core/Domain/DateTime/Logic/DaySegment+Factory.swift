//
//  DaySegment+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

import Foundation

extension DaySegment {
    /// Создает часть суток по дате.
    /// - Parameters:
    ///   - date: Дата, по часу которой определяется часть суток.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Часть суток.
    static func from(date: Date, using calendar: Calendar = .current) -> DaySegment {
        from(hour: date.hour(using: calendar))
    }
    
    /// Создает часть суток по календарной дате и времени.
    /// - Parameters:
    ///   - civilDateTime: Календарная дата и время, по часу которых определяется часть суток.
    ///   - calendar: Календарь для вычислений. По умолчанию `.utc`.
    /// - Returns: Часть суток.
    static func from(civilDateTime: CivilDateTime, using calendar: Calendar = .utc) -> DaySegment {
        from(hour: civilDateTime.storedDate.hour(using: calendar))
    }
    
    /// Создает часть суток по часу.
    /// - Parameter hour: Час в 24-часовом формате.
    /// - Returns: Часть суток.
    static func from(hour: Int) -> DaySegment {
        switch hour {
        case 3..<6: .dawn
        case 6..<9: .earlyMorning
        case 9..<12: .morning
        case 12..<15: .afternoon
        case 15..<18: .lateAfternoon
        case 18..<21: .evening
        case 21..<24: .lateEvening
        default: .night
        }
    }
}
