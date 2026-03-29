//
//  DateDisplayFormatter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import Foundation

struct DateDisplayFormatter {
    static let calendar = Calendar.current

    static func format(_ date: Date, showsTime: Bool = true) -> String {
        let year = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: Date())
        let formatter = Foundation.DateFormatter()

        formatter.calendar = calendar
        let dateTemplate = year == currentYear ? "dMMM" : "dMMMy"
        formatter.setLocalizedDateFormatFromTemplate(showsTime ? "\(dateTemplate)jm" : dateTemplate)

        return formatter.string(from: date)
    }

    static func formatRange(startDate: Date, endDate: Date, showsTime: Bool = false) -> String {
        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)
        let currentYear = calendar.component(.year, from: Date())
        let formatter = DateIntervalFormatter()

        formatter.calendar = calendar
        let dateTemplate = (startYear == endYear && startYear == currentYear) ? "dMMM" : "dMMMy"
        formatter.dateTemplate = showsTime ? "\(dateTemplate)jm" : dateTemplate

        return formatter.string(from: startDate, to: endDate)
    }
}
