//
//  DateDisplayFormatter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import Foundation

struct DateDisplayFormatter {
    // MARK: - Stored Properties
    
    static let calendar = Calendar.current

    // MARK: - Public Methods
    
    static func format(_ date: Date, showsTime: Bool = true) -> String {
        let dateTemplate = isInCurrentYear(date) ? "dMMM" : "dMMMy"
        return makeDateFormatter(dateTemplate: dateTemplate, showsTime: showsTime).string(from: date)
    }

    static func formatRange(startDate: Date, endDate: Date, showsTime: Bool = false) -> String {
        let dateTemplate = isSameYear(startDate, endDate) ? "dMMM" : "dMy"
        return makeIntervalFormatter(dateTemplate: dateTemplate, showsTime: showsTime).string(from: startDate, to: endDate)
    }

    // MARK: - Private Methods
    
    private static func isSameYear(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.component(.year, from: lhs) == calendar.component(.year, from: rhs)
    }

    private static func isInCurrentYear(_ date: Date) -> Bool {
        calendar.component(.year, from: date) == calendar.component(.year, from: Date())
    }

    private static func templateWithOptionalTime(dateTemplate: String, showsTime: Bool) -> String {
        showsTime ? "\(dateTemplate)jm" : dateTemplate
    }

    private static func makeDateFormatter(dateTemplate: String, showsTime: Bool) -> Foundation.DateFormatter {
        let formatter = Foundation.DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate(
            templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        )
        return formatter
    }

    private static func makeIntervalFormatter(dateTemplate: String, showsTime: Bool) -> DateIntervalFormatter {
        let formatter = DateIntervalFormatter()
        formatter.calendar = calendar
        formatter.dateTemplate = templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        return formatter
    }
}
