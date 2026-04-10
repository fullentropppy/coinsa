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
    
    static func formatRelative(_ date: Date, showsTime: Bool = true) -> String {
        if date.isTomorrow {
            String(localized: .tomorrow)
        } else if date.isToday {
            String(localized: .today)
        } else if date.isYesterday {
            String(localized: .yesterday)
        } else {
            format(date, showsTime: showsTime)
        }
    }
    
    static func format(_ date: Date, showsTime: Bool = true) -> String {
        let dateTemplate = isSameYear(.now, date) ? "dMMMM" : "dMMMMy"
        
        let formatter = Foundation.DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate(
            templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        )
        
        return formatter.string(from: date)
    }

    static func formatRange(startDate: Date, endDate: Date, showsTime: Bool = false) -> String {
        let dateTemplate = isSameYear(startDate, endDate) && isSameYear(.now, startDate) ? "dMMMM" : "dMy"
        
        let formatter = DateIntervalFormatter()
        formatter.calendar = calendar
        formatter.dateTemplate = templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        
        return formatter.string(from: startDate, to: endDate)
    }

    // MARK: - Private Methods
    
    private static func isSameYear(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.component(.year, from: lhs) == calendar.component(.year, from: rhs)
    }

    private static func templateWithOptionalTime(dateTemplate: String, showsTime: Bool) -> String {
        showsTime ? "\(dateTemplate)jm" : dateTemplate
    }
}
