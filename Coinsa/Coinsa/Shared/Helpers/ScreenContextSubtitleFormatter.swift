//
//  ScreenContextSubtitleFormatter.swift
//  Coinsa
//
//  Created by Codex on 28.03.2026.
//

import Foundation

struct ScreenContextSubtitleFormatter {
    static func format(parentTitle: String, startDate: Date, endDate: Date) -> String {
        let dateRange = formatDateRange(
            startDate: startDate,
            endDate: endDate
        )

        guard !parentTitle.isEmpty else {
            return dateRange
        }

        return "\(parentTitle) • \(dateRange)"
    }

    static func formatDateRange(startDate: Date, endDate: Date) -> String {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)
        let formatter = DateIntervalFormatter()
        
        formatter.calendar = calendar
        formatter.dateTemplate = startYear == endYear ? "dMMM" : "dMMMy"

        return formatter.string(from: startDate, to: endDate)
    }
}
