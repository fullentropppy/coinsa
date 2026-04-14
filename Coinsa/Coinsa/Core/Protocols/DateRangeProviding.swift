//
//  DateRangeProviding.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.03.2026.
//

import Foundation

// MARK: - Протокол

protocol DateRangeProviding {
    var startDate: Date { get }
    var endDate: Date { get }
}

// MARK: - Стандартная реализация

extension DateRangeProviding {
    var durationInDays: Int {
        let duration = endDate.days(from: startDate)
        return duration == 0 ? 1 : Int(duration)
    }
    
    var range: ClosedRange<Date> {
        startDate...endDate
    }
}
