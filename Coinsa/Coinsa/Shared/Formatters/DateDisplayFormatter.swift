//
//  DateDisplayFormatter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.03.2026.
//

import Foundation

struct DateDisplayFormatter {
    // MARK: - Публичные методы
    
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
        let dateTemplate = Date().isSameYear(as: date) ? "dMMMM" : "dMMMMy"
        
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(
            templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        )
        
        return formatter.string(from: date)
    }

    static func formatRange(startDate: Date, endDate: Date, showsTime: Bool = false) -> String {
        let dateTemplate = startDate.isSameYear(as: endDate) && Date().isSameYear(as: startDate) ? "dMMMM" : "dMy"
        
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = templateWithOptionalTime(dateTemplate: dateTemplate, showsTime: showsTime)
        
        return formatter.string(from: startDate, to: endDate)
    }

    // MARK: - Внутренние методы

    private static func templateWithOptionalTime(dateTemplate: String, showsTime: Bool) -> String {
        showsTime ? "\(dateTemplate)jm" : dateTemplate
    }
}
