//
//  Date+Formatting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import Foundation

extension Date {
    // MARK: - Single date
    
    static var tripDisplayFormat: Date.FormatStyle {
        .dateTime
            .year()
            .month(.defaultDigits)
            .day()
    }

    // MARK: - Date interval
    
    static var tripIntervalFormat: Date.IntervalFormatStyle {
        .interval
            .year()
            .month(.defaultDigits)
            .day()
    }
}
