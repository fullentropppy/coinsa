//
//  Date+Formatting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import Foundation

extension Date {
    // MARK: - Single Date
    
    static var displayFormat: Date.FormatStyle {
        .dateTime.year().month(.defaultDigits).day()
    }
    
    static var displayFormatWithTime: Date.FormatStyle {
        .dateTime.year().month(.defaultDigits).day().hour().minute()
    }

    // MARK: - Date Interval
    
    static var intervalFormat: Date.IntervalFormatStyle {
        .interval.year().month(.defaultDigits).day()
    }
}
